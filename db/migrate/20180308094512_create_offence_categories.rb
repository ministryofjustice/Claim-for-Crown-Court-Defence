class CreateOffenceCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :offence_categories do |t|
      t.integer :number
      t.string :description

      t.timestamps null: false
    end
  end
end
