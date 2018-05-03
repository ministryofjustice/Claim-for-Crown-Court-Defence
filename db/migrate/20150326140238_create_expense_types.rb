class CreateExpenseTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :expense_types do |t|
      t.string :name

      t.timestamps null: true
    end
    add_index :expense_types, :name
  end
end
