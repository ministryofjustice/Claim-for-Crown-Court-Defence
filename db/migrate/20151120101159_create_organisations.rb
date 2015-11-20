class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :supplier_number
      t.string :organisation_type
      t.boolean :vat_registered
      t.uuid :uuid
      t.uuid :api_key

      t.timestamps null: false
    end
    add_index :organisations, :name
    add_index :organisations, :supplier_number
    add_index :organisations, :organisation_type
  end
end
