# Query object for the room exporter
class RoomExporterQuery < Exportling::ExporterQuery
  # When this query object is initialised by the house exporter, it may pass a scoped relation
  def initialize(options, relation = Room.all)
    @options  = options
    @relation = relation
  end

  # Which of the provided params do we use to find the appropriate records
  def query_options
    @options.try(:[], :room)
  end
end
