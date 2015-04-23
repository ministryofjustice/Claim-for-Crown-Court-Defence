class CreateOffences < ActiveRecord::Migration
  def change
    create_table :offences do |t|
      t.string :description
      t.string :offence_class

      t.timestamps
    end
  end
end
