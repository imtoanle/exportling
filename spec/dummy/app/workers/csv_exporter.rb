module CsvExporter
  extend ActiveSupport::Concern

  included do
    # Called at the start of parent perform
    # Open a new csv file, and add field headers
    def on_start
      csv_temp_path = "#{Rails.root}/tmp/exports/#{@export.file_name}"
      @csv = CSV.open(csv_temp_path, 'wb')
      @csv << field_names
    end

    # Called for each entry of parent perform
    def on_entry(export_data)
      @csv << export_data.attributes.values_at(*field_names)
    end

    # Called at end of parent perform
    # Write the CSV to file
    def on_finish
      @csv.close_write
      @csv
    end
  end
end
