class AddDeletedAtToExternalUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :external_users, :deleted_at, :datetime, default: nil
  end
end
