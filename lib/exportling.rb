require "exportling/engine"

module Exportling
  # Allow application to specify the owner of the export
  mattr_accessor :export_owner_class

  def self.export_owner_class
    @@export_owner_class.constantize
  end
end
