class AddDeletedAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :deleted_at, :datetime, default: nil
  end
end
