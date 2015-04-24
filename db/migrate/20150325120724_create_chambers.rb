class CreateChambers < ActiveRecord::Migration
  def change
    create_table :chambers do |t|
      t.string :name
      t.string :supplier_no

      t.timestamps
    end
    add_index :chambers, :name
    add_index :chambers, :supplier_no
  end
end
