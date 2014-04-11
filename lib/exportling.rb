require "exportling/engine"

module Exportling
  mattr_accessor :export_owner_class, :base_storage_directory

  # Allow the base application to set the owner of the export
  def self.export_owner_class
    @@export_owner_class.constantize
  end

  # Allow the base application to set the export directory
  # Defaults to Rails.root/exportling
  def self.base_storage_directory
    @@base_storage_directory || 'exportling'
  end
end
