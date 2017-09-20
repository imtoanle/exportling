require "exportling/engine"

module Exportling
  mattr_accessor :export_owner_class, :export_owner_method,
    :export_file_name_suffix, :base_storage_directory, :raise_on_fail,
    :authorization_mechanism, :s3_bucket_name, :store_dir

  # Allow the base application to set the owner of the export
  def self.export_owner_class
    @@export_owner_class.constantize
  end

  # Allow base application to define the method to find the current owner
  def self.export_owner_method
    @@export_owner_method
  end

  # Allow the base application to provide a suffix that should be applied to
  # export file names
  def self.export_file_name_suffix
    @@export_file_name_suffix || ""
  end

  # When an export fails, should the exporter raise the error
  def self.raise_on_fail
    @@raise_on_fail || false
  end

  # Allow the base application to set the export directory
  # Defaults to Rails.root/exportling
  def self.base_storage_directory
    @@base_storage_directory || 'exportling'
  end

  # Allow base application to define which authorization mechanism (e.g. :pundit)
  # to use
  def self.authorization_mechanism
    @@authorization_mechanism || nil
  end

  def self.s3_bucket_name
    @@s3_bucket_name
  end

  def self.store_dir
    @@store_dir || -> (model){ "exports/#{model.owner_id}" }
  end
end
