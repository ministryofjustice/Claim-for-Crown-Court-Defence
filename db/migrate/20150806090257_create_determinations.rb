class CreateDeterminations < ActiveRecord::Migration
  def change
    create_table :determinations do |t|
      t.integer :claim_id
      t.string :type
      t.decimal :fees
      t.decimal :expenses
      t.decimal :total

      t.timestamps null: true
    end
  end
end
