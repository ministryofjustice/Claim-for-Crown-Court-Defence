class AddDeletedAtToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :deleted_at, :datetime, default: nil
  end
end
