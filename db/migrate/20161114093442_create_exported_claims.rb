class CreateExportedClaims < ActiveRecord::Migration
  def change
    create_table :exported_claims do |t|
      t.references :claim, index: true, null: false
      t.uuid :claim_uuid, index: true, null: false
      t.string :status
      t.integer :status_code
      t.integer :retries, default: 0, null: false
      t.timestamps
      t.datetime :last_request_at
    end
  end
end
