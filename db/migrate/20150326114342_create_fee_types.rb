class CreateFeeTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :fee_types do |t|
      t.string :description
      t.string :code

      t.timestamps null: true
    end
    add_index :fee_types, :description
    add_index :fee_types, :code
  end
end
