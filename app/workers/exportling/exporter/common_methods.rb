module Exportling
  module Exporter::CommonMethods
    extend ActiveSupport::Concern
    def to_required_attributes_hash(export_data)
      export_data.attributes.select do |field_name, field_value|
        field_names.include?(field_name)
      end
    end
  end
end
