class AddMultiFirmUserLinks < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :multi_firm_user, :boolean, default: false, null: false

    create_table :multi_firm_user_links, id: :integer do |t|
      t.references :user, type: :integer, null: false, index: false,
                          foreign_key: { on_delete: :cascade }
      t.references :linked_user, type: :integer, null: false, index: false,
                                 foreign_key: { to_table: :users, on_delete: :cascade }

      t.timestamps
    end

    add_index :multi_firm_user_links, %i[user_id linked_user_id], unique: true
    add_index :multi_firm_user_links, :linked_user_id, unique: true
    add_check_constraint :multi_firm_user_links, 'user_id <> linked_user_id',
                         name: 'multi_firm_user_links_different_users'
  end
end
