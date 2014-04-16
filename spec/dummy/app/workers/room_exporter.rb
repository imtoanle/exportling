# Room exporter. Could be used as root exporter, which would export all rooms to a csv file
class RoomExporter < Exportling::Exporter
  export_field :id
  export_field :name
  export_field :house_id

  query_class RoomExporterQuery

  def on_start(temp_file=nil)
  end

  def on_entry(export_data, associated_data=nil)
  end

  def on_finish
  end

  def save_entry(export_data, associated_data=nil)
    @export_entries ||= []
    @export_entries << export_data.name
  end

  # Join the room names before sending them back to the parent house exporter
  def export_entries
    @export_entries.join('|') if @export_entries.present?
  end
end
