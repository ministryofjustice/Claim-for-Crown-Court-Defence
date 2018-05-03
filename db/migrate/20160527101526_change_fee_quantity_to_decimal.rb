class ChangeFeeQuantityToDecimal < ActiveRecord::Migration[4.2]
  def up
    change_column :fees, :quantity,  :decimal
  end

  def down
    change_column :fees, :quantity,  :integer
  end
end
