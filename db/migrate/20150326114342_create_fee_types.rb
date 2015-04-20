class CreateFeeTypes < ActiveRecord::Migration
  def change
    create_table :fee_types do |t|
      t.string :description
      t.string :code
      t.references :fee_category, index: true

      t.timestamps
    end
    add_index :fee_types, :description
    add_index :fee_types, :code
  end
end
