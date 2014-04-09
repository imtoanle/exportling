# Base exporter class. Other export classes will extend this class
# TODO: Provide mechanism to alter fields at runtime
module Exportling
  class Exporter
    # This class is also responsible for queueing up the export into Sidekiq
    include Sidekiq::Worker
    sidekiq_options queue: 'exportling_exports'

    class << self
      attr_accessor :export_fields
      attr_accessor :query

      # This will allow the extending class to specify fields as:
      # export_field :field_name
      def export_field(name)
        self.export_fields ||= []
        self.export_fields << name
      end

      def fields
        export_fields || []
      end

      def query_class(klass=nil)
        self.query = klass unless klass.nil?
        self.query
      end
    end

    # Access to class instance variables =============================
    def fields
      self.class.fields
    end

    def field_names
      @field_names ||= fields.map(&:to_s)
    end

    def query_class
      self.class.query_class
    end

    # Worker Methods ============================================================
    # Shortcut to instance peform method
    def self.perform(export_id)
      new.perform(export_id)
    end

    def perform(export_id)
      @export = Exportling::Export.find(export_id)

      # Don't perform export more than once (idempotence)
      return if @export.completed?

      @temp_export_file = Tempfile.new('export')
      on_start(@temp_export_file)

      find_each do |export_data|
        on_entry(export_data)
      end

      finish_export

      # If there was an issue during the export process, make sure we fail the export
      # Not implemented error will be raised if the export classes haven't been set up properly
    rescue ::StandardError, ::NotImplementedError => e
      @export.fail!
    ensure
      @temp_export_file.unlink unless @temp_export_file.nil?
      @temp_export_file = nil
    end

    # Calls the on_finish callback, attaches the generated file to the model then deletes the temp file.
    # Finally, flags the export as complete
    def finish_export
      on_finish

      # Save the generated file against the export object
      @export.output = @temp_export_file
      @export.save!

      @export.complete!
    end

    # Use model from export object, and pass query params to it
    def find_each(&block)
      query_class.new(@export.params).find_each(&block)
    end

    # Abstract Methods ================================================================
    # The temp file is accessable to the entire class, so accepting it as an argument isn't really needed
    # However, requiring it to be accepted as a param by on_start helps enforce its use by extending classes
    def on_start(temp_file)
      raise ::NotImplementedError, 'on_start must be implemented in the extending class, and must accept a file'
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
