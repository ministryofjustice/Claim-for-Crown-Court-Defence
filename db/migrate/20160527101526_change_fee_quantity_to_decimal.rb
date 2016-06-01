class ChangeFeeQuantityToDecimal < ActiveRecord::Migration
  def up
    change_column :fees, :quantity,  :decimal
  end

  def down
    change_column :fees, :quantity,  :integer
  end
end
