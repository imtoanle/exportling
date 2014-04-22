# This migration comes from exportling (originally 20140224031757)
class CreateExport < ActiveRecord::Migration
  def change
    create_table :exportling_exports do |t|
      t.references :owner
      t.string :klass, null: false
      t.string :status, null: false, default: 'created'
      t.string :file_type, null: false
      t.string :output
      t.text :params
      t.timestamps
    end
  end
end
