class CreateMessages < ActiveRecord::Migration[4.2]
  def change
    create_table :messages do |t|
      t.string :subject
      t.text :body
      t.references :claim, index: true
      t.integer :sender_id
      t.integer :recipient_id

      t.timestamps null: true
    end
    add_index :messages, :sender_id
    add_index :messages, :recipient_id
  end
end
