# Base exporter class. Other export classes will extend this class
# Class will act like a view/presenter, to make model data available for the export process
# REVISE: See if the data selection/presentation should be defined elsewhere. We may just want to make this a fairly dumb exporter
# TODO: Provide mechanism to specify query object (this may be the klass of the export object)
# TODO: Provide mechanism to alter fields at runtime (maybe)
module Exportling
  class Exporter
    # This class is also responsible for queueing up the export into Sidekiq
    include ::Sidekiq::Worker
    sidekiq_options queue: 'exportling_exports'

    class << self
      attr_accessor :export_fields

      # This will allow the extending class to specify fields as:
      # export_field :field_name
      # TODO: Match this up to how the user would want to specify export fields
      #
      def export_field(name)
        # May not need a proxy. Just need to be able to store a field
        self.export_fields ||= []
        self.export_fields << name
      end

      def fields
        self.export_fields || []
      end
    end


    # Perform the actual export work
    # Make this an abstract method for now (will probably define some useful default behaviour here)
    # args will probably just be an export_id. This method will fetch the export, and perform any actions from there
    # TODO: This class is responsible for a lot (both storage and performance). See if we can split up at some point
    def perform(export_id)
      p "Performing background export"
      # ... Do something
    end

    # Present all specified fields as a hash/object
    def fields
      self.class.fields
    end
  end
end
