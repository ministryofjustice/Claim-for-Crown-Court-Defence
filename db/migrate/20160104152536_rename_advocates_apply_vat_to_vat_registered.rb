class RenameAdvocatesApplyVatToVatRegistered < ActiveRecord::Migration
  def change
    rename_column :advocates, :apply_vat, :vat_registered
  end
end
