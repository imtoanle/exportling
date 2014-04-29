class Exportling::Export < ActiveRecord::Base
  belongs_to :owner, class_name: Exportling.export_owner_class.to_s

  validates :name, presence: true
  validates :klass, presence: true
  validates :file_type, presence: true

  serialize :params

  mount_uploader :output, ExportUploader

  # Sidekiq worker class that will perform the export
  def worker_class
    klass.constantize
  end

  def completed?
    status == 'completed'
  end

  def incomplete?
    !completed?
  end

  def failed?
    status.downcase == 'failed'
  end

  def processing?
    status == 'processing'
  end

  def file_name
    "#{id}_#{name.parameterize}_#{created_at.strftime('%Y-%m-%d')}.#{file_type}"
  end

  def set_processing!
    update_attributes(status: 'processing')
  end

  def complete!
    update_attributes(status: 'completed')
  end

  def fail!
    update_attributes(status: 'failed')
  end

  # TODO: Create async_perform! (when Sidekiq working)
  def perform!
    worker_class.perform(id)
  end
end
