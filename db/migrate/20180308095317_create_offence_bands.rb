class CreateOffenceBands < ActiveRecord::Migration[4.2]
  def change
    create_table :offence_bands do |t|
      t.integer :number
      t.string :description
      t.references :offence_category, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
