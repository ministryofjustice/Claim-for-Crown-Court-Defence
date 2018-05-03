class CreateFees < ActiveRecord::Migration[4.2]
  def change
    create_table :fees do |t|
      t.references :claim, index: true
      t.references :fee_type, index: true

      t.integer :quantity
      t.decimal :rate
      t.decimal :amount

      t.timestamps null: true
    end
  end
end
