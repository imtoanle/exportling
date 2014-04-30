class AddElapsedTime < ActiveRecord::Migration
  def change
    add_column :exportling_exports, :started_at, :datetime
    add_column :exportling_exports, :completed_at, :datetime
  end
end
