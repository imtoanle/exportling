# Query object for the room exporter
class RoomExporterQuery
  # When this query object is initialised by the house exporter, it may pass a scoped relation
  def initialize(options)
    @options  = options
  end

  def find_each(&block)
    query_options = @options[:room]
    if query_options.present?
      Room.where(query_options).find_each(&block)
    end
  end
end
