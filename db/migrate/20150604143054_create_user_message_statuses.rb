class CreateUserMessageStatuses < ActiveRecord::Migration
  def change
    create_table :user_message_statuses do |t|
      t.references :user, index: true
      t.references :message, index: true
      t.boolean :read, default: false

      t.timestamps
    end
    add_index :user_message_statuses, :read
  end
end
