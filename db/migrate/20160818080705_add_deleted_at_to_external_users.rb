class AddDeletedAtToExternalUsers < ActiveRecord::Migration
  def change
    add_column :external_users, :deleted_at, :datetime, default: nil
  end
end
