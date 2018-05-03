class CreateAdvocates < ActiveRecord::Migration[4.2]
  def change
    create_table :advocates do |t|
      t.string :role

      t.string :first_name
      t.string :last_name

      t.references :chamber, index: true

      t.timestamps null: true
    end
    add_index :advocates, :role
  end
end
