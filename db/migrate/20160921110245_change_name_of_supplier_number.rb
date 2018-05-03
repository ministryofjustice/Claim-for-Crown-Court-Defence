class ChangeNameOfSupplierNumber < ActiveRecord::Migration[4.2]
  def up
    rename_column :providers, :supplier_number, :firm_agfs_supplier_number
  end

  def down
    rename_column :providers, :firm_agfs_supplier_number, :supplier_number
  end
end
