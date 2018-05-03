class AddMaxValuesToFeeTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :fee_types, :max_amount, :decimal, default_value: nil
  end
end
