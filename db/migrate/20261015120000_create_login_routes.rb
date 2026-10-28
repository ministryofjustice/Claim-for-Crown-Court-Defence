class CreateLoginRoutes < ActiveRecord::Migration[8.1]
  def up
    create_login_routes unless table_exists?(:login_routes)
    change_column_default :login_routes, :id, nil
    unless check_constraint_exists?(:login_routes, name: 'login_routes_login_method_check')
      add_check_constraint :login_routes, "login_method IN ('legacy', 'entra')",
                           name: 'login_routes_login_method_check'
    end
    populate_login_routes
  end

  def down
    drop_table :login_routes
  end

  private

  def create_login_routes
    create_table :login_routes, id: :integer, default: nil do |t|
      t.string :login_method, null: false, default: 'legacy'
      t.timestamps
    end

    add_foreign_key :login_routes, :users, column: :id, on_delete: :cascade
  end

  def populate_login_routes
    execute <<~SQL
      INSERT INTO login_routes (id, created_at, updated_at)
      SELECT id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM users
      ON CONFLICT (id) DO NOTHING
    SQL
  end
end
