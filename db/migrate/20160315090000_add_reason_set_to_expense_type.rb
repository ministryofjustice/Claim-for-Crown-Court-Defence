class AddReasonSetToExpenseType < ActiveRecord::Migration[4.2]
  def change
    add_column :expense_types, :reason_set, :string

    ExpenseType.reset_column_information
    execute "UPDATE expense_types SET reason_set='A'"
    execute "UPDATE expense_types SET reason_set='B' WHERE name = 'Other'"
  end
end
