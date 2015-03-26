class CreateFees < ActiveRecord::Migration
  def change
    create_table :fees do |t|
      t.string :description
      t.string :code
      t.integer :quantity
      t.decimal :rate
      t.decimal :amount
      t.references :fee_type, index: true

      t.timestamps
    end
    add_index :fees, :description
    add_index :fees, :code
  end
end
