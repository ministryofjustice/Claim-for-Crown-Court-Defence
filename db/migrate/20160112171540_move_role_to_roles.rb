class MoveRoleToRoles < ActiveRecord::Migration[4.2]
  def change
    add_column :external_users, :roles, :string
    add_column :case_workers, :roles, :string

    [CaseWorker, ExternalUser].each do |model|
      model.all.each do |record|
        record.roles << record.role
        record.save!
      end
    end

    remove_column :external_users, :role
    remove_column :case_workers, :role
  end
end
