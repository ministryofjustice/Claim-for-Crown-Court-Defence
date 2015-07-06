class AddQuantityModifierToFeeTypes < ActiveRecord::Migration
  def change
    add_column :fee_types, :quantity_modifier, :integer
  end
end
