module Exportling
  class ExportDecorator < Draper::Decorator
    delegate_all

    def download_path
      "/exportling/export/#{object.owner_id}/#{object.id}/#{object.file_name}"
    end
  end
end
