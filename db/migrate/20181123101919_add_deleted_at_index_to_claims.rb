class AddDeletedAtIndexToClaims < ActiveRecord::Migration[5.0]
  def change
    add_index :claims, :deleted_at
  end
end
