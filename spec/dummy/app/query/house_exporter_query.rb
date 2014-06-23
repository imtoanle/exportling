# Query object for the house exporter
class HouseExporterQuery
  def initialize(options, owner)
    @options  = options
  end

  def find_each(&block)
    query_options = @options[:house]
    if query_options.present?
      House.where(@options[:house]).find_each(&block)
    end
  end
end
