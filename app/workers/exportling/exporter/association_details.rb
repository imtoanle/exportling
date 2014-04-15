# Holds the details for a single associated export
module Exportling
  class Exporter::AssociationDetails
    attr_accessor :exporter_class, :callbacks, :params

    def initialize(options)
      @exporter_class = options[:exporter_class]
      @callbacks      = options[:callbacks]
      @params         = Exporter::AssociationParams.new(options[:params])
    end

    # The options to pass to a child exporter
    def child_options(context_object)
      {
        as:         :child,
        callbacks:  @callbacks,
        params:     params.replaced_params(context_object)
      }
    end
  end
end
