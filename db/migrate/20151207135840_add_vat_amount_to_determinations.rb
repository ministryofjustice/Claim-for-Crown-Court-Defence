class AddVatAmountToDeterminations < ActiveRecord::Migration
  def change
    add_column :determinations, :vat_amount, :float, default: 0.0
  end
end
