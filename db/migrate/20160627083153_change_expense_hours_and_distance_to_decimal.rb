class ChangeExpenseHoursAndDistanceToDecimal < ActiveRecord::Migration[4.2]
  def up
    change_column :expenses, :hours, :decimal
    change_column :expenses, :distance, :decimal
  end

  def down
    change_column :expenses, :hours, :integer
    change_column :expenses, :distance, :integer
  end
end
