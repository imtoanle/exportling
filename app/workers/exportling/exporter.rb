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
    def self.perform(export_id, options={})
      new.perform(export_id, options)
    end

    # Allow options { as: :child } to be passed, which will not create any files, or flag the export as complete
    def perform(export_id, options={})
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
      @export.fail! if @export
    end


      end
    end

    # Takes all associations for this exporter, and requests their data
    def associated_data_for(context_object)
      associations.each do |assoc_name, assoc_details|

        assoc_details.exporter_class.perform(@export.id, assoc_details.child_options(context_object))
      end
    end

    # Abstract Methods ================================================================
    # The temp file is an instance variable, so accepting it as an argument isn't really needed
    # However, requiring it to be accepted as a param by on_start helps enforce its use by extending classes
    def on_start(temp_file=nil)
      raise ::NotImplementedError, 'on_start must be implemented in the extending class'
    end

    def on_finish
      raise ::NotImplementedError, 'on_finish must be implemented in the extending class'
    end

    # Called for each entry of perform
    def on_entry(export_data)
      raise ::NotImplementedError, 'Handling of each entry (on_entry) must be performed in the extending class'
    end
  end
end
