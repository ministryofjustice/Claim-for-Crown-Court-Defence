class AddIndexToClaimsOnUuid < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def change
    add_index :claims, :uuid, unique: true, algorithm: :concurrently
  end
end
