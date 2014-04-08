# Base exporter class. Other export classes will extend this class
# TODO: Provide mechanism to alter fields at runtime
module Exportling
  class Exporter
    # This class is also responsible for queueing up the export into Sidekiq
    include ::Sidekiq::Worker
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
        self.export_fields || []
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

      on_start

      find_each do |export_data|
        on_entry(export_data)
      end

      on_finish

      # Mark the export as complete
      @export.complete!

      # If there was an issue during the export process, make sure we fail the export
      # Not implemented error will be raised if the export classes haven't been set up properly
    rescue ::StandardError, ::NotImplementedError => e
      @export.fail!
    end

    # Use model from export object, and pass query params to it
    def find_each(&block)
      query_class.new(@export.params).find_each(&block)
    end

    # Abstract Methods ================================================================
    # No need for errors on start/finish, as the extending class may not need additional setup/teardown
    def on_start
    end

    def on_finish
    end

    # Called for each entry of perform
    def on_entry(export_data)
      raise ::NotImplementedError, 'Handling of each entry (on_entry) must be performed in the extending class'
    end
  end
end
