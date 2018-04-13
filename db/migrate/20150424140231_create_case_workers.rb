class CreateCaseWorkers < ActiveRecord::Migration
  def change
    create_table :case_workers do |t|
      t.string :role

      t.timestamps null: true
    end
    add_index :case_workers, :role
  end
end
