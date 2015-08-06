class AddExpenseReferenceToDatesAttended < ActiveRecord::Migration
  def change
    add_reference :dates_attended, :expense, index: true
  end
end
