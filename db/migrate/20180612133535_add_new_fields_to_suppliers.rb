class AddNewFieldsToSuppliers < ActiveRecord::Migration[5.0]
  def change
    add_column :supplier_numbers, :name, :string
    add_column :supplier_numbers, :postcode, :string
  end
end
