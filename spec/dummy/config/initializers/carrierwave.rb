require "exportling/export_uploader"
CarrierWave.configure { |config| Strata::CarrierWaveConfigurator.new(config).apply }
