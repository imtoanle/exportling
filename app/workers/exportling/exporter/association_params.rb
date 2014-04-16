module Exportling
  class Exporter::AssociationParams
    def initialize(options)
      @param_hash = options
    end

    def replaced_params(context_object)
      @param_hash.inject({}) do |return_hash, (association_key, params)|
        return_hash[association_key] =
          params.inject({}) do |return_params, (param_key, param_value)|
            return_params[param_key] = param_value
            if param_value.is_a?(Symbol)
              return_params[param_key] = replace_param(context_object, param_value)
            end
            return_params
          end
        return_hash
      end
    end

    def replace_param(context_object, param_symbol)
      if context_object.respond_to?(param_symbol)
        context_object.send(param_symbol)
      else
        error_message = "Export Association Error - #{context_object.class} does not respond to '#{param_symbol}'"
        raise ArgumentError, error_message
      end
    end

  end
end
