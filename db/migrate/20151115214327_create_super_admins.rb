class CreateSuperAdmins < ActiveRecord::Migration[4.2]
  def change
    create_table :super_admins do |t|
      t.timestamps null: true
    end
  end
end
