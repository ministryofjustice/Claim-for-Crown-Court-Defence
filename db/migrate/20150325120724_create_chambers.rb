class CreateChambers < ActiveRecord::Migration
  def change
    create_table :chambers do |t|
      t.string :name

      t.timestamps
    end
    add_index :chambers, :name
  end
end
