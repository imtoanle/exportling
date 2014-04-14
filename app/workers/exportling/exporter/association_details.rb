module Exportling
  class Exporter::AssociationDetails
    attr_accessor :exporter_class, :callbacks, :params

    def initialize(options)
      @exporter_class = options[:exporter_class]
      @callbacks      = options[:callbacks]
      @params         = AssociationParams.new(options[:params])
    end
  end
end
