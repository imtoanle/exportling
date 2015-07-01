class Exportling::Export < ActiveRecord::Base
  belongs_to :owner, class_name: Exportling.export_owner_class.to_s

  validates :name, presence: true
  validates :klass, presence: true
  validates :file_type, presence: true

  serialize :params

  mount_uploader :output, Exportling::ExportUploader

  # Sidekiq worker class that will perform the export
  def worker_class
    klass.constantize
  end

  # Which class should we try to authorize export permissions against?
  # Only needed when using Pundit
  def authorize_on_class
    class_name = worker_class.authorize_on_class_name
    class_name.constantize if class_name.present?
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

  def processed?
    %w{failed completed}.include?(status)
  end

  def file_missing?
    !file_exists?
  end

  def file_exists?
    output.file.try(:exists?)
  end

  def file_name
    "#{id}_#{name.parameterize}_#{created_at.strftime('%Y-%m-%d')}.#{file_type}"
  end

  def set_processing!
    update_attributes(status: 'processing',
                      started_at: Time.zone.now)
  end

  def complete!
    update_attributes(status: 'completed',
                      completed_at: Time.zone.now)
  end

  def fail!
    update_attributes(status: 'failed',
                      completed_at: Time.zone.now)
  end

  # Perform the export
  def perform!
    worker_class.perform(id)
  end

  # Perform the export as a background job with Sidekiq
  def perform_async!
    worker_class.perform_async(id)
  end
end
