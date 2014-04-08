# Query object for the house exporter
class HouseExporterQuery < Exportling::ExporterQuery
  def initialize(options, relation = House.all)
    @options  = options
    @relation = relation
  end

  # Which of the provided params do we use to find the appropriate records
  def query_options
    @options.try(:[], :house)
  end
end
