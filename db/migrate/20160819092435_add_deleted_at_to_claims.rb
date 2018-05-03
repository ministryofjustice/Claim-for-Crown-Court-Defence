class AddDeletedAtToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :deleted_at, :datetime, default: nil
  end
end
