class CreateFees < ActiveRecord::Migration
  def change
    create_table :fees do |t|
      t.string :description
      t.string :code
      t.references :fee_type, index: true

      t.timestamps
    end
    add_index :fees, :description
    add_index :fees, :code
  end
end
