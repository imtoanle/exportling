require "exportling/engine"

module Exportling
  mattr_accessor :export_owner_class, :export_owner_method, :base_storage_directory

  # Allow the base application to set the owner of the export
  def self.export_owner_class
    @@export_owner_class.constantize
  end

  # Allow base application to define the method to find the current owner
  def self.export_owner_method
    @@export_owner_method
  end

  # Allow the base application to set the export directory
  # Defaults to Rails.root/exportling
  def self.base_storage_directory
    @@base_storage_directory || 'exportling'
  end
end
