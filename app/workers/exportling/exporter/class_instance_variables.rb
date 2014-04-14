module Exportling
  module Exporter::ClassInstanceVariables
    extend ActiveSupport::Concern

    included do
      delegate :fields, :field_names, :query_class, :associations, to: :class
    end

    module ClassMethods
      attr_accessor :export_fields
      attr_accessor :export_field_names
      attr_accessor :export_associations
      attr_accessor :query

      # This will allow the extending class to specify fields as:
      # export_field :field_name
      def export_field(name)
        self.export_fields ||= []
        self.export_fields << name
      end

      def fields
        export_fields || []
      end

      def field_names
        self.export_field_names ||= fields.map(&:to_s)
      end

      # This will allow the extending class to specify fields as:
      # export_association { association_name: AssociationExporter }
      # TODO: Allow additional options
      def export_association(details)
        self.export_associations ||= {}
        self.export_associations.merge!(details)
      end

      def associations
        export_associations || {}
      end

      def query_class(klass=nil)
        self.query = klass unless klass.nil?
        self.query
      end
    end
  end
end
