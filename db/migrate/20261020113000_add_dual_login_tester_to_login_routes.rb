class AddDualLoginTesterToLoginRoutes < ActiveRecord::Migration[8.1]
  def change
    add_column :login_routes, :dual_login_tester, :boolean, default: false, null: false
  end
end
