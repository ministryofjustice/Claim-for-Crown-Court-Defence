class AddClaimIdIndexToDeterminations < ActiveRecord::Migration[5.0]
  self.disable_ddl_transaction!

  def change
    add_index :determinations, :claim_id, algorithm: :concurrently
  end
end
