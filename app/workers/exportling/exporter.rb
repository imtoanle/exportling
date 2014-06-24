# Base exporter class. Other export classes will extend this class
# TODO: Provide mechanism to alter fields at runtime
module Exportling
  class Exporter
    # This class is also responsible for queueing up the export into Sidekiq
    include Sidekiq::Worker
    sidekiq_options queue: 'exportling_exports'

    # export_entries is the default storage place of export data
    # Upon triggering a child export, the parent export calls export_entries to fetch the child data
    attr_accessor :export_entries

    include ClassInstanceVariables
    include RootExporterMethods
    include ChildExporterMethods
    include CommonMethods

    def initialize
      @export_entries ||= []
    end

    # Worker Methods ============================================================
    # Shortcut to instance peform method
    def self.perform(export_id, options = {})
      new.perform(export_id, options)
    end

    # Allow options { as: :child } to be passed, which will not create any files, or flag the export as complete
    def perform(export_id, options = {})
      @export  = Exportling::Export.find(export_id)
      @options = options
      @child   = options[:as] == :child

      # Don't perform export more than once (idempotence)
      return if @export.completed?

      @export.set_processing!

      # Run the rest of the export as if we are a root or child exporter, depending on perform arguments
      if @child
        perform_as_child
      else
        perform_as_root
      end

    # If there was an issue during the export process, make sure we fail the export
    # Not implemented error will be raised if the export classes haven't been set up properly
    rescue ::StandardError, ::NotImplementedError => e
      log_error(e)
      @export.fail! if @export
      raise e if Exportling.raise_on_fail
    end

    def log_error(exception)
      if defined? NewRelic
        NewRelic::Agent.agent.error_collector.notice_error(exception)
      end
    end

    # Use model from export object, and pass query params to it
    def find_each(&block)
      query_class_name.constantize.
        new(query_params, @export.owner).
        find_each(&block)
    end

    # Merges the export params and object params (if set)
    def query_params
      params_from_options = @options.try(:[], :params)
      params_from_export  = @export.params || {}
      return {} if params_from_export.blank? && params_from_options.blank?

      params_from_export.tap do |search_params|
        if params_from_options.present?
          search_params.deep_merge!(@options[:params])
        end
      end
    end

    # Takes all associations for this exporter, and requests their data
    def associated_data_for(context_object)
      associations.inject({}) do |associated_data, (assoc_name, assoc_details)|
        exporter = assoc_details.exporter_class.new
        exporter.perform(@export.id, assoc_details.child_options(context_object))
        associated_data[assoc_name] = exporter.export_entries
        associated_data
      end
    end

    # Caches the results of each entry
    # By default, just saves the entry in an array
    # Often overwritten in the extending class
    def save_entry(export_data, associated_data = nil)
      @export_entries << export_data
    end

    # Abstract Methods ================================================================
    # Called at the start of perform
    # Use this method to accept the temp file, and set up anything required
    #  for this export
    def on_start(temp_file = nil)
    end

    # Called at the end of perform. Use this to complete file writing +
    #  any other teardown required
    def on_finish
    end

    # Called for each entry of perform
    # If writing data to a file, do so here
    def on_entry(export_data, associated_data = nil)
    end
  end
end
