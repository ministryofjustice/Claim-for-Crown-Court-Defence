class CreateOffenceClasses < ActiveRecord::Migration[4.2]
  def change
    create_table :offence_classes do |t|
      t.string :class_letter
      t.string :description

      t.timestamps null: true
    end
    add_index :offence_classes, :class_letter
    add_index :offence_classes, :description
  end
end
