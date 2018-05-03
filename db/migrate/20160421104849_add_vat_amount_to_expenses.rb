class AddVatAmountToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :vat_amount, :decimal, default: 0.0
  end
end
