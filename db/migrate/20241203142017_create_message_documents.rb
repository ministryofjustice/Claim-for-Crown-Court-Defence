class CreateMessageDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :message_documents do |t|
      t.integer :message_id
      t.integer :external_user_id
      t.string :uuid
      t.string :form_id
      t.integer :creator_id
      t.integer :verified_file_size
      t.string :file_path
      t.boolean :verified

      t.timestamps
    end
    add_index :message_documents, :message_id
    add_index :message_documents, :external_user_id
    add_index :message_documents, :creator_id
  end
end
