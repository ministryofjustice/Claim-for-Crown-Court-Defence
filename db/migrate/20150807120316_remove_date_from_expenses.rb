class RemoveDateFromExpenses < ActiveRecord::Migration[4.2]
  def change
    remove_column :expenses, :date, :datetime
  end
end
