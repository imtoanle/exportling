module Exportling
  module Exporter::ClassInstanceVariables
    extend ActiveSupport::Concern

    included do
      delegate :fields, :field_names, :query_class_name, :associations, to: :class
    end

    module ClassMethods
      attr_accessor :export_fields
      attr_accessor :export_field_names
      attr_accessor :export_associations
      attr_accessor :query_name
      attr_accessor :authorize_on_name

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
      def export_association(details)
        self.export_associations ||= {}
        self.export_associations =
          details.inject(self.export_associations) do |associations, (assoc_key, assoc_details)|
            associations[assoc_key] = Exportling::Exporter::AssociationDetails.new(assoc_details)
            associations
          end
      end

      def associations
        export_associations || {}
      end

      def query_class_name(klass_name = nil)
        self.query_name = klass_name unless klass_name.nil?
        query_name
      end

      def authorize_on_class_name(klass_name = nil)
        self.authorize_on_name = klass_name unless klass_name.nil?
        authorize_on_name
      end
    end
  end
end
