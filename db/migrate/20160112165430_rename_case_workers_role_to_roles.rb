class RenameCaseWorkersRoleToRoles < ActiveRecord::Migration
  def change
    rename_column :case_workers, :role, :roles
  end
end
