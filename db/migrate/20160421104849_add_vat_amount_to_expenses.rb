class AddVatAmountToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :vat_amount, :decimal, default: 0.0
  end
end
