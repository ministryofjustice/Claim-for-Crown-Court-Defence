class CreateCaseWorkers < ActiveRecord::Migration
  def change
    create_table :case_workers do |t|
      t.string :role

      t.timestamps
    end
    add_index :case_workers, :role
  end
end
