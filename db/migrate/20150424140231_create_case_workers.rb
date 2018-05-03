class CreateCaseWorkers < ActiveRecord::Migration[4.2]
  def change
    create_table :case_workers do |t|
      t.string :role

      t.timestamps null: true
    end
    add_index :case_workers, :role
  end
end
