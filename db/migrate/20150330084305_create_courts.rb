class CreateCourts < ActiveRecord::Migration
  def change
    create_table :courts do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
    add_index :courts, :code
    add_index :courts, :name
  end
end
