class AddSupplierNumberToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :supplier_number, :string
  end
end
