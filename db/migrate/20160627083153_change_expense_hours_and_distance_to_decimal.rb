class ChangeExpenseHoursAndDistanceToDecimal < ActiveRecord::Migration
  def up
    change_column :expenses, :hours, :decimal
    change_column :expenses, :distance, :decimal
  end

  def down
    change_column :expenses, :hours, :integer
    change_column :expenses, :distance, :integer
  end
end
