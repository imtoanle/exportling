# This migration comes from exportling (originally 20140429071012)
class AddNameToExport < ActiveRecord::Migration
  def change
    add_column :exportling_exports, :name, :string, null: false, default: ''
  end
end
