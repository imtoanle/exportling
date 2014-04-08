# FIXME: This exporter only exports CSV files, regardless of export file type
class HouseExporter < Exportling::Exporter
  export_field :id
  export_field :price
  export_field :square_meters

  query_object HouseExporterQuery

  include CsvExporter
end
