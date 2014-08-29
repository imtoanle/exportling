class ExportRequest < Hashie::Trash
  include Hashie::Extensions::IndifferentAccess
  property :klass
  property :name
  property :file_type
  property :params
end
