class CreateExport < ActiveRecord::Migration
  def change
    create_table :exportling_exports do |t|
      t.belongs_to :user
      t.string :klass, null: false, default: ''
      t.string :method, null: false, default: ''
      t.string :status, null: false, default: 'created'
      t.string :file
      t.text :params
      t.timestamps
    end
  end
end
