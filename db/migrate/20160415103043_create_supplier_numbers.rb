class CreateSupplierNumbers < ActiveRecord::Migration[4.2]
  def change
    create_table :supplier_numbers do |t|
      t.integer :provider_id
      t.string :supplier_number
    end
  end
end
