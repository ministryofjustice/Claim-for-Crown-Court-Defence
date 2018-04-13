class CreateOffenceClasses < ActiveRecord::Migration
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
