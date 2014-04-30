module Exportling
  module Exporter::RootExporterMethods
    extend ActiveSupport::Concern
    # Top level export
    # This is the export method that will be called for the entry Exporter
    def perform_as_root
      @temp_export_file = Tempfile.new('export')
      on_start(@temp_export_file)

      find_each do |export_data|
        # If the object has any specified associations, fetch data from them now
        associated_data = associated_data_for(export_data)

        # save data to instance variable (has default behaviour)
        save_entry(export_data, associated_data)

        # process data (no default behaviour)
        on_entry(export_data, associated_data)

      end

      # Attach generated file to export and flag as complete
      finish_root_export

    ensure
      @temp_export_file.unlink unless @temp_export_file.nil?
      @temp_export_file = nil
    end

    # Calls the on_finish callback and attaches the generated file to the model
    # Finally, flags the export as complete
    def finish_root_export
      on_finish

      # Save the generated file against the export object
      @export.transaction do
        @export.output = @temp_export_file
        @export.save!
        @export.complete!
      end
    end
  end
end
