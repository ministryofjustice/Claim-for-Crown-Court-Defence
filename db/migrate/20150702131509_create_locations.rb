class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name

      t.timestamps null: true
    end
    add_index :locations, :name
  end
end
