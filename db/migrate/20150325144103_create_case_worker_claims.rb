class CreateCaseWorkerClaims < ActiveRecord::Migration[4.2]
  def change
    create_table :case_worker_claims do |t|
      t.references :case_worker, index: true
      t.references :claim, index: true

      t.timestamps null: true
    end
  end
end
