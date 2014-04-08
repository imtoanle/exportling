class Exportling::Export < ActiveRecord::Base
  belongs_to :owner, class_name: Exportling.export_owner_class.to_s

  validates :klass, presence: true
  validates :file_type, presence: true

  serialize :params

  mount_uploader :output, ::CarrierWave::Uploader::Base

  # Sidekiq worker class that will perform the export
  def worker_class
    klass.constantize
  end

  def completed?
    status == 'completed'
  end

  def file_name
    "#{id}_#{klass}_#{created_at.strftime('%Y-%m-%d')}.#{file_type}"
  end

  def complete!
    update_attributes(status: 'completed')
  end

  def fail!
    update_attributes(status: 'failed')
  end
end
