class AddIndexToFeesOnUuid < ActiveRecord::Migration[7.0]
  self.disable_ddl_transaction!

  def change
     add_index :fees, :uuid, unique: true, algorithm: :concurrently
  end
end
