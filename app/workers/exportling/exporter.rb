# Base exporter class. Other export classes will extend this class
# TODO: Provide mechanism to alter fields at runtime
module Exportling
  class Exporter
    # This class is also responsible for queueing up the export into Sidekiq
    include Sidekiq::Worker
    sidekiq_options queue: 'exportling_exports'

    include ClassInstanceVariables
    include RootExporterMethods
    include ChildExporterMethods

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

      # Run the rest of the export as if we are a root or child exporter, depending on perform arguments
      if @child
        perform_as_child
      else
        perform_as_root
      end

    # If there was an issue during the export process, make sure we fail the export
    # Not implemented error will be raised if the export classes haven't been set up properly
    rescue ::StandardError, ::NotImplementedError => e
      # TODO: Log error somewhere useful (airbrake or similar?)
      p "Export Failed! #{e.message}"
      @export.fail! if @export
    end

    # Use model from export object, and pass query params to it
    def find_each(&block)
      query_class.new(query_params).find_each(&block)
    end

    # Merges the export params and object params (if set)
    def query_params
      @export.params.tap do |search_params|
        if @options.try(:[], :params).present?
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
      @export_entries ||= []
      @export_entries << export_data
    end

    # Overwritten in the extending class if we want to process all exported data before it reaches the parent
    def export_entries
      @export_entries
    end

    # Abstract Methods ================================================================
    # The temp file is an instance variable, so accepting it as an argument isn't really needed
    # However, requiring it to be accepted as a param by on_start helps enforce its use by extending classes
    def on_start(temp_file = nil)
      raise ::NotImplementedError, 'on_start must be implemented in the extending class'
    end

    def on_finish
      raise ::NotImplementedError, 'on_finish must be implemented in the extending class'
    end

    # Called for each entry of perform
    def on_entry(export_data, associated_data = nil)
      raise ::NotImplementedError, 'Handling of each entry (on_entry) must be performed in the extending class'
    end
  end
end
