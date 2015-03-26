class CreateFeeTypes < ActiveRecord::Migration
  def change
    create_table :fee_types do |t|
      t.string :name

      t.timestamps
    end
    add_index :fee_types, :name
  end
end
