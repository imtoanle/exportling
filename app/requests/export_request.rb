class ExportRequest
  include ActiveModel::Model

  attr_accessor :klass, :name, :file_type, :params

  def to_hash
    {
      klass: klass,
      name: name,
      file_type: file_type,
      params: params
    }
  end
end
