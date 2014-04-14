# FIXME: This exporter only exports CSV files, regardless of export file type
class RoomExporter < Exportling::Exporter
  export_field :id
  export_field :name
  export_field :house_id

  query_class RoomExporterQuery
end
