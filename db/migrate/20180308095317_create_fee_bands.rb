class CreateFeeBands < ActiveRecord::Migration
  def change
    create_table :fee_bands do |t|
      t.integer :number
      t.string :description
      t.references :fee_category, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
