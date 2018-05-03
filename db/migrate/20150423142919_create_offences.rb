class CreateOffences < ActiveRecord::Migration[4.2]
  def change
    create_table :offences do |t|
      t.string :description
      t.references :offence_class, index: true

      t.timestamps null: true
    end
  end
end
