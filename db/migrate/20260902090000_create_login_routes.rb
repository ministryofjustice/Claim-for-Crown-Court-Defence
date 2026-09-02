class CreateLoginRoutes < ActiveRecord::Migration[8.1]
  def change
    # Interim routing table: the primary key is the user's id, so the whole
    # table can be dropped once every account uses a single login method.
    create_table :login_routes, id: :integer do |t|
      t.string :login_method, null: false, default: 'legacy'

      t.timestamps
    end

    add_foreign_key :login_routes, :users, column: :id, on_delete: :cascade
  end
end
