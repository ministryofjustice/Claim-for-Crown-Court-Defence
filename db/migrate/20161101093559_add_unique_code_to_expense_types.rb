class AddUniqueCodeToExpenseTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :expense_types, :unique_code, :string
    add_index :expense_types, :unique_code, unique: true
  end
end
