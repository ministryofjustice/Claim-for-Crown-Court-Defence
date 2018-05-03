class RenameAdvocateAccountNumbertoSupplierNumber < ActiveRecord::Migration[4.2]
def self.up
    rename_column :advocates, :account_number, :supplier_number
    rename_column :chambers, :account_number, :supplier_number
  end

  def self.down
    rename_column :advocates, :supplier_number, :account_number
    rename_column :chambers, :supplier_number, :account_number
  end
end
