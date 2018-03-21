class CreateOffenceCategories < ActiveRecord::Migration
  def change
    create_table :offence_categories do |t|
      t.integer :number
      t.string :description

      t.timestamps null: false
    end
  end
end
