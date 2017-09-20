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
      if Exportling.store_dir.respond_to?(:call)
        Exportling.store_dir.call(model)
      else
        Exportling.store_dir
      end
    end

    def cache_dir
      "#{Rails.root}/tmp/exportling/exports/#{model.owner_id}"
    end
  end
end
