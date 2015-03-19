# encoding: utf-8

module Exportling
  class ExportUploader < CarrierWave::Uploader::Base

    storage :fog

    def fog_directory
      if Exportling.s3_bucket_name.respond_to?(:call)
        Exportling.s3_bucket_name.call
      else
        Exportling.s3_bucket_name
      end
    end

    def store_dir
      "exports/#{model.owner_id}"
    end

    def cache_dir
      "#{Rails.root}/tmp/exportling/exports/#{model.owner_id}"
    end

    def fog_attributes
      {'Content-Disposition' => 'attachment'}
    end
  end
end
