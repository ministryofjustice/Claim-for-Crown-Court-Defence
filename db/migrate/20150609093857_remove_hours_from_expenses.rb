class RemoveHoursFromExpenses < ActiveRecord::Migration[4.2]
  def change
    remove_column :expenses, :hours
  end
end
