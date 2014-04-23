## This query object is just here as an example, and is not used by any export.
# As the query objects are defined in the main application, all activerecord
# extensions/hacks are still available. In the following class, the export params
# are those expected by ransack, and have been saved under the key ':q'.
# e.g. export.params # => { q: { name_eq: 'a name' } }

class RansackExporterQueryExample
  def initialize(options={})
    @options = options
  end

  def find_each(&block)
    query_options = @options[:q]
    search = YourClass.search(query_options)
    search.result(distinct: true).find_each(&block)
  end
end
