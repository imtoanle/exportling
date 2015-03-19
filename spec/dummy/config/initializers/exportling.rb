# Set the owner of the export
Exportling.export_owner_class  = 'User'

# The method to call to get the current owner (method must be available to the application controller)
Exportling.export_owner_method = :current_export_owner

# Set where exports are stored
Exportling.base_storage_directory = 'custom_exportling_directory'

# Don't raise on fail (will be set to true for specific specs)
Exportling.raise_on_fail = false

Exportling.s3_bucket_name = 'exportling_spec_directory'
