# encoding: utf-8

module Exportling
  class ExportUploader < CarrierWave::Uploader::Base

    storage :file

    def store_dir
      "#{Rails.root}/#{Exportling.base_storage_directory}/exports/#{model.owner_id}"
    end

    def cache_dir
      "#{Rails.root}/#{Exportling.base_storage_directory}/tmp/exports/#{model.owner_id}"
    end
  end
end
