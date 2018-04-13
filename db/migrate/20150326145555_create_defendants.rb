class CreateDefendants < ActiveRecord::Migration
  def change
    create_table :defendants do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.datetime :date_of_birth
      t.datetime :representation_order_date
      t.boolean :order_for_judicial_apportionment
      t.string :maat_reference
      t.references :claim, index: true

      t.timestamps null: true
    end
  end
end
