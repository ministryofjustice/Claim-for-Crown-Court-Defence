class AddFieldsToExpenses < ActiveRecord::Migration[4.2]
  def up
    add_column :expenses, :distance, :integer
    add_column :expenses, :mileage_rate_id, :integer
    add_column :expenses, :date, :date
    add_column :expenses, :hours, :integer
  end

  def down
    remove_column :expenses, :distance
    remove_column :expenses, :mileage_rate_id
    remove_column :expenses, :date
    remove_column :expenses, :hours
  end
end
