class AddSupplierNumberToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :supplier_number, :string
  end
end
