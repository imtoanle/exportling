class Exportling::Export < ActiveRecord::Base
  belongs_to :owner, class_name: Exportling.export_owner_class.to_s

  validates :method, presence: true
  validates :klass, presence: true
  validates :file_type, presence: true

  mount_uploader :output, ::CarrierWave::Uploader::Base

  def completed?
    true || status == 'completed'
  end

  def file_name
    "#{id}_#{klass}_#{created_at.strftime('%Y-%m-%d')}.#{file_type}"
  end
end
