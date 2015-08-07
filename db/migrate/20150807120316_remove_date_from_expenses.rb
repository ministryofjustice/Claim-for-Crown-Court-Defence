class RemoveDateFromExpenses < ActiveRecord::Migration
  def change
    remove_column :expenses, :date, :datetime
  end
end
