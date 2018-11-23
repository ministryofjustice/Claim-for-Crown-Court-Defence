class AddDeletedAtIndexToClaims < ActiveRecord::Migration[5.0]
  self.disable_ddl_transaction!

  def change
    add_index :claims, :deleted_at, algorithm: :concurrently
  end
end
