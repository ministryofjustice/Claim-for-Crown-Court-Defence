class AddMaxValuesToFeeTypes < ActiveRecord::Migration
  def change
    add_column :fee_types, :max_amount, :decimal, default_value: nil
  end
end
