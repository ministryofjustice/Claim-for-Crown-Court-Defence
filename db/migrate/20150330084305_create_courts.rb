class CreateCourts < ActiveRecord::Migration
  def change
    create_table :courts do |t|
      t.string :code
      t.string :name
      t.string :court_type

      t.timestamps null: true
    end
    add_index :courts, :code
    add_index :courts, :name
    add_index :courts, :court_type
  end
end
