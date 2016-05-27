class AddQuantityIsDecimalToFeeType < ActiveRecord::Migration
  def change
    add_column :fee_types, :quantity_is_decimal, :boolean, default: false
  end
end
