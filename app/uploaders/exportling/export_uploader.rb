# encoding: utf-8

module Exportling
  class ExportUploader < CarrierWave::Uploader::Base
    storage :file

    def store_dir
      "#{Rails.root}/#{model.class.to_s.underscore}/#{model.owner_id}/#{model.id}"
    end

    def cache_dir
      "#{Rails.root}/tmp/#{model.class.to_s.underscore}/#{model.owner_id}/#{model.id}"
    end
  end
end
