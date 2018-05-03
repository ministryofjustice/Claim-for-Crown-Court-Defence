class CreateProviders < ActiveRecord::Migration[4.2]
  def change
    create_table :providers do |t|
      t.string :name
      t.string :supplier_number
      t.string :provider_type
      t.boolean :vat_registered
      t.uuid :uuid
      t.uuid :api_key

      t.timestamps null: false
    end
    add_index :providers, :name
    add_index :providers, :supplier_number
    add_index :providers, :provider_type
  end
end
