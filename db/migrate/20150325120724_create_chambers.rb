class CreateChambers < ActiveRecord::Migration
  def change
    create_table :chambers do |t|
      t.string :name
      t.string :account_number
      t.boolean :vat_registered

      t.timestamps null: true
    end
    add_index :chambers, :name
    add_index :chambers, :account_number
  end
end
