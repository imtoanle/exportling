class AddNameToExport < ActiveRecord::Migration
  def change
    add_column :exportling_exports, :name, :string, null: false, default: ''
  end
end
