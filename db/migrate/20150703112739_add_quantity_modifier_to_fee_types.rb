class AddQuantityModifierToFeeTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :fee_types, :quantity_modifier, :integer
  end
end
