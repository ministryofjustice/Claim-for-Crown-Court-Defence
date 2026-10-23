class CreateLoginRoutes < ActiveRecord::Migration[8.1]
  def up
    # Interim routing table: the primary key is the user's id, so the whole
    # table can be dropped once every account uses a single login method.
    create_table :login_routes, id: :integer do |t|
      t.string :login_method, null: false, default: 'legacy'

      t.timestamps
    end

    add_foreign_key :login_routes, :users, column: :id, on_delete: :cascade

    execute <<~SQL.squish
      INSERT INTO login_routes (id, login_method, created_at, updated_at)
      SELECT users.id, 'legacy', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM users
    SQL
  end

  def down
    drop_table :login_routes
  end
end
