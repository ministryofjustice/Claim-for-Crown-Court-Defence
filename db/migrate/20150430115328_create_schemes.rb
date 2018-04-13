class CreateSchemes < ActiveRecord::Migration
  def change
    create_table :schemes do |t|
      t.string :name

      t.timestamps null: true
    end
    add_index :schemes, :name
  end
end
