class HouseExporter < Exportling::Exporter
  export_field :id
  export_field :price
  export_field :square_meters

  query_class HouseExporterQuery

  export_association rooms: {
    exporter_class: RoomExporter,
    callbacks:      { on_entry: 'on_room', on_finished: 'on_rooms_finished' },
    params:         { room: { house_id: :id } }
  }

  def on_start(temp_file)
    @csv = CSV.open(temp_file, 'wb')
    @csv << (field_names + ['room_names'])
  end

  def on_entry(export_data, associated_data=nil)
    # Data from this house
    row_data = export_data.attributes.values_at(*field_names)
    # Data from child rooms of this house (just collate names)
    row_data << associated_data[:rooms] unless associated_data.nil?
    # Write to file
    @csv << row_data
  end

  def on_finish
    @csv.close_write
  end
end
