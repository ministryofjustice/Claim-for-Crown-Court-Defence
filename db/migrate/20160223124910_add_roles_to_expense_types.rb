class AddRolesToExpenseTypes < ActiveRecord::Migration
  def change
    add_column :expense_types, :roles, :string

    ExpenseType.all.each do |expense_type|
      expense_type.roles << 'agfs'
      expense_type.save!
    end
  end
end
