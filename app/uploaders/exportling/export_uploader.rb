# encoding: utf-8
module Exportling
  class ExportUploader < CarrierWave::Uploader::Base
    include Strata::Uploader

    def directory_name
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
  end
end
