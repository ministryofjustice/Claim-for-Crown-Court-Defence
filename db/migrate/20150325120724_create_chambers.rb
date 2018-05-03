class CreateChambers < ActiveRecord::Migration[4.2]
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
