# encoding: utf-8

module Exportling
  class ExportUploader < CarrierWave::Uploader::Base

    storage :file

    def base_dir
      "#{Rails.root}/#{Exportling.base_storage_directory}"
    end

    def store_dir
      "#{base_dir}/exports/#{model.owner_id}"
    end

    def cache_dir
      "#{base_dir}/tmp/exports/#{model.owner_id}"
    end
  end
end
