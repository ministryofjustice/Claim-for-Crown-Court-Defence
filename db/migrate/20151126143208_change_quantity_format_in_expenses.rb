class ChangeQuantityFormatInExpenses < ActiveRecord::Migration
  def up
    change_column :expenses, :quantity, :float
  end

  def down
    change_column :expenses, :quantity, :decimal
  end
end
