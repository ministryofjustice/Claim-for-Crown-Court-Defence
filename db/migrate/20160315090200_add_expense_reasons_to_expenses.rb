class AddExpenseReasonsToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :reason_id, :integer
    add_column :expenses, :reason_text, :string
  end
end
