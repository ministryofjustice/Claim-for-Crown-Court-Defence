class RemoveQuantityModifierFromFeeTypes < ActiveRecord::Migration[4.2]
  def change
    remove_column :fee_types, :quantity_modifier, :integer
  end
end
