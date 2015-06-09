class RemoveHoursFromExpenses < ActiveRecord::Migration
  def change
    remove_column :expenses, :hours
  end
end
