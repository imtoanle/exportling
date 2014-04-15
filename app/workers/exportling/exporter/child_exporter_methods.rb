module Exportling
  module Exporter::ChildExporterMethods
    extend ActiveSupport::Concern
    def perform_as_child
      on_start

      find_each do |export_data|
        on_entry(export_data)
        associated_data_for(export_data)
      end

      on_finish
    end
  end
end
