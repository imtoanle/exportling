module Exportling
  module ExporterDefaultQuery
    extend ActiveSupport::Concern

    class KeyMissingError       < StandardError; end
    class RelationMissingError  < StandardError; end

    module ClassMethods
      attr_reader :key, :relation_klass

      def query_options_key(key)
        @key = key
      end

      def relation_class(klass)
        @relation_klass = klass
      end
    end

    included do
      delegate :key, :relation_klass, to: :class

      # Default behaviour for an exporter query object
      def initialize(options={})
        @options = options
        validate_initial_state
      end

      def find_each(&block)
        query_options = @options[key]
        if query_options.present?
          relation_klass.where(query_options).find_each(&block)
        end
      end

      # ========================== Usage Validations ==========================
      # Validate that the developer is using the default query correctly
      def validate_initial_state
        validate_key_set
        validate_relation_set
      end

      def validate_key_set
        return unless key.blank?
        error_message = 'Use query_options_key :foo to define the key that'\
                        'should be used in the query'
        raise KeyMissingError, error_message
      end

      def validate_relation_set
        return unless relation_klass.blank?
        error_message = 'Use relation_class :foo to define the relation to'\
                        'query'
        raise RelationMissingError, error_message
      end
    end
  end
end
