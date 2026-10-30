class CreateLoginRoutes < ActiveRecord::Migration[8.1]
  def up
    create_table :login_routes, id: :integer, default: nil do |t|
      t.string :login_method, null: false, default: 'legacy'
      t.timestamps
      t.check_constraint "login_method IN ('legacy', 'entra')", name: 'login_routes_login_method_check'
    end

    add_foreign_key :login_routes, :users, column: :id, on_delete: :cascade
    populate_login_routes
  end

  def down
    drop_table :login_routes
  end

  private

  def populate_login_routes
    execute <<~SQL
      INSERT INTO login_routes (id, created_at, updated_at)
      SELECT id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM users
    SQL
  end
end
