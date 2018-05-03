class CreateUserMessageStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :user_message_statuses do |t|
      t.references :user, index: true
      t.references :message, index: true
      t.boolean :read, default: false

      t.timestamps null: true
    end
    add_index :user_message_statuses, :read
  end
end
