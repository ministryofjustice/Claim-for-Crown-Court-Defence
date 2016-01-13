class MoveRoleToRoles < ActiveRecord::Migration
  def change
    add_column :external_users, :roles, :string
    add_column :case_workers, :roles, :string

    ExternalUser.all.each { |external_user| external_user.roles << external_user.role }

    CaseWorker.all.each do |case_worker|
      if case_worker.role == 'admin'
        case_worker.roles << 'admin'
      else
        case_worker.roles << 'case_worker'
      end
    end

    remove_column :external_users, :role
    remove_column :case_workers, :role
  end
end
