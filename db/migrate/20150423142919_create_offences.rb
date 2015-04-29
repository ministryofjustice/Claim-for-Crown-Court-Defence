class CreateOffences < ActiveRecord::Migration
  def change
    create_table :offences do |t|
      t.string :description
      t.references :offence_class, index: true

      t.timestamps
    end
  end
end
