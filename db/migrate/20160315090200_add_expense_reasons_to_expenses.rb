class AddExpenseReasonsToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :reason_id, :integer
    add_column :expenses, :reason_text, :string
  end
end
