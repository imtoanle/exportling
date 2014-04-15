class HouseExporter < Exportling::Exporter
  export_field :id
  export_field :price
  export_field :square_meters

  query_class HouseExporterQuery

  # Need to be able to find this id on the fly in the base exporter
  # Can probably assume/enforce that any field referenced here will be included in the export (e.g. id)
  export_association rooms: {
    exporter_class: RoomExporter,
    callbacks:      { on_entry: 'on_room', on_finished: 'on_rooms_finished' },
    params:         { room: { house_id: :id } }
  }

  include CsvExporter
end
