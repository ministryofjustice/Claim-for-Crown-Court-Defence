class RenameAdvocateIdToExternalUserId < ActiveRecord::Migration
  def change
    rename_column :claims, :advocate_id, :external_user_id
    rename_column :documents, :advocate_id, :external_user_id
  end
end
