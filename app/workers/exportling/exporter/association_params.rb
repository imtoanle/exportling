module Exportling
  class Exporter::AssociationParams
    def initialize(options)
      @param_hash = options
    end

    # Returns the params for this association, with any of the placeholder symbols replaced with values from context_object
    def replaced_params(context_object)
      @param_hash.inject({}) do |return_hash, (association_key, association_params)|
        return_hash[association_key] = replace_association_params(context_object, association_params)
        return_hash
      end
    end

    # Accepts the params for a single association
    # If any of the param values are symbols, it passes them to replace_param_symbol
    # Otherwise, values are returned unchanged
    def replace_association_params(context_object, association_params)
      association_params.inject({}) do |return_params, (param_key, param_value)|
        return_params[param_key] = param_value
        if param_value.is_a?(Symbol)
          return_params[param_key] = replace_param_symbol(context_object, param_value)
        end
        return_params
      end
    end

    # Calls the method named by the symbol on the context object and returns the response
    # Raises an error if the context object does not respond to the method name
    def replace_param_symbol(context_object, param_symbol)
      if context_object.respond_to?(param_symbol)
        context_object.send(param_symbol)
      else
        error_message = "Export Association Error - #{context_object.class} does not respond to '#{param_symbol}'"
        raise ArgumentError, error_message
      end
    end

  end
end
