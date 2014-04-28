# Set the owner of the export
Exportling.export_owner_class  = 'User'

# The method to call to get the current owner (method must be available to the application controller)
Exportling.export_owner_method = :current_export_owner

# Set where exports are stored
Exportling.base_storage_directory = 'custom_exportling_directory'
