class AddVatAmountsToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :fees_vat, :decimal, default: 0.0
    add_column :claims, :expenses_vat, :decimal, default: 0.0
    add_column :claims, :disbursements_vat, :decimal, default: 0.0
  end
end
