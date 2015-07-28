class RemoveQuantityModifierFromFeeTypes < ActiveRecord::Migration
  def change
    remove_column :fee_types, :quantity_modifier, :integer
  end
end
