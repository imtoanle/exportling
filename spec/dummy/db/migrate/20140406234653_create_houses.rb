class CreateHouses < ActiveRecord::Migration
  def change
    create_table :houses do |t|
      t.integer :square_meters
      t.integer :price
      t.boolean :furnished

      t.timestamps
    end
  end
end
