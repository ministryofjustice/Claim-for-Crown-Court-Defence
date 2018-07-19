class AddLocationTypeToExpenses < ActiveRecord::Migration[5.0]
  def change
    add_column :expenses, :location_type, :string
  end
end
