class CreateCaseTypesTable < ActiveRecord::Migration
  def change
    create_table :case_types do |t|
      t.string :name
      t.boolean :is_fixed_fee
      t.timestamps null: true
    end
  end
end
