class RenameAdvocateAccountNumbertoSupplierNumber < ActiveRecord::Migration
def self.up
    rename_column :advocates, :account_number, :supplier_number
    rename_column :chambers, :account_number, :supplier_number
  end

  def self.down
    rename_column :advocates, :supplier_number, :account_number
    rename_column :chambers, :supplier_number, :account_number
  end
end
