class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.references :expense_type, index: true
      t.references :claim, index: true
      t.datetime :date
      t.string :location
      t.integer :quantity
      t.decimal :rate
      t.decimal :hours
      t.decimal :amount

      t.timestamps null: true
    end
  end
end
