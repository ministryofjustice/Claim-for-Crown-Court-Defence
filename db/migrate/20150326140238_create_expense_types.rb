class CreateExpenseTypes < ActiveRecord::Migration
  def change
    create_table :expense_types do |t|
      t.string :name

      t.timestamps
    end
    add_index :expense_types, :name
  end
end
