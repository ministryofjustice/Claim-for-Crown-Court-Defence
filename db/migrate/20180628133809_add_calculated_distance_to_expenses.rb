class AddCalculatedDistanceToExpenses < ActiveRecord::Migration[5.0]
  def change
    add_column :expenses, :calculated_distance, :decimal
  end
end
