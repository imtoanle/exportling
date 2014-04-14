# FIXME: This exporter only exports CSV files, regardless of export file type
class HouseExporter < Exportling::Exporter
  export_field :id
  export_field :price
  export_field :square_meters

  query_class HouseExporterQuery

  # TODO: Find way to specify additional options to pass to the exporter (e.g. the id of the current house)
  export_association rooms: RoomExporter

  include CsvExporter
end
