class RenameExternalUsersRoleToRoles < ActiveRecord::Migration
  def change
    rename_column :external_users, :role, :roles
  end
end
