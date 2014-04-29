class AddNameToExport < ActiveRecord::Migration
  def change
    add_column :exporting_exports, :name, :string, null: false, default: ''
  end
end
