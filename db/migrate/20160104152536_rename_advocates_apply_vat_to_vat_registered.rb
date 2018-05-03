class RenameAdvocatesApplyVatToVatRegistered < ActiveRecord::Migration[4.2]
  def change
    rename_column :advocates, :apply_vat, :vat_registered
  end
end
