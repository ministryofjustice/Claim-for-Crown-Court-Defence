class AddVatToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :vat_amount, :decimal, default: 0.0
  end
end
