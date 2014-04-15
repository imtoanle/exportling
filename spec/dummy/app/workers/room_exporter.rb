# Room exporter. Could be used as root exporter, which would export all rooms to a csv file
class RoomExporter < Exportling::Exporter
  export_field :id
  export_field :name
  export_field :house_id

  query_class RoomExporterQuery

  def on_start(temp_file=nil)
    # byebug
    # Maybe write data to passed file (if present)
  end

  def on_entry
    # byebug
    # Maybe pass result back to parent (e.g. could specify that parent has callback specified on_room_entry)
    # Or cache results
    # Or write to file
  end

  def on_finish
    # byebug
    # Either pass cached results back to parent
    # Or notify parent that results are done for this association
    # Or Flush file buffer
  end
end
