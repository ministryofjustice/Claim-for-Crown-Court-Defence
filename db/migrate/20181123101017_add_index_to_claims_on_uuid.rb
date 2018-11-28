class AddIndexToClaimsOnUuid < ActiveRecord::Migration[5.0]
  self.disable_ddl_transaction!

  def change
    add_index :claims, :uuid, unique: true, algorithm: :concurrently
  end
end
