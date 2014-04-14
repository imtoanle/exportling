# Query object for the room exporter
class RoomExporterQuery < Exportling::ExporterQuery
  def initialize(options, relation = Room.all)
    @options  = options
    @relation = relation
  end

  # Which of the provided params do we use to find the appropriate records
  def query_options
    @options.try(:[], :room)
  end
end
