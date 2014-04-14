require 'fileutils'

# Set the export storage directory to a specific test one
Exportling.base_storage_directory = 'exportling_spec_directory'

# Make sure we remove all uploaded files
RSpec.configure do |config|
  config.before(:suite) do
    if Exportling.base_storage_directory.present?
      FileUtils.rm_rf("#{Rails.root}/#{Exportling.base_storage_directory}")
    end
  end
  config.after(:suite) do
    if Exportling.base_storage_directory.present?
      FileUtils.rm_rf("#{Rails.root}/#{Exportling.base_storage_directory}")
    end
  end
end
