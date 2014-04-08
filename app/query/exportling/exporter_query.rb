module Exportling
  class ExporterQuery
    # This should be overwritten in the extending class
    # e.g. initialise(options, relation=House.all)
    def initialize(options, relation)
      @options  = options
      @relation = relation
    end


    def find_each(&block)
      if query_options.present?
        # TODO: Only select fields needed by exporter
        @relation.where(query_options).find_each(&block)
      end
    end

    # These are the options used to query for the correct models
    # This method will be based on the export params
    # Expected that these will be along the lines of { model_name: { model_attr_key: model_attr_value } }
    # e.g. { house: { furnished: false } }
    def query_options
      raise ::NotImplementedError, 'query_options must be implemented in the extending class'
    end
  end
end
