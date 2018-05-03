class CreateDatesAttended < ActiveRecord::Migration[4.2]
  def change
    create_table :dates_attended do |t|
      t.datetime :date
      t.references :fee, index: true

      t.timestamps null: true
    end
  end
end
