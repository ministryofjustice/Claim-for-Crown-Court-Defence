class AddAttachmentAttachmentToMessages < ActiveRecord::Migration[4.2]
  def self.up
    change_table :messages do |t|
      # Paperclip attachment are created using:
      #   t.attachment :attachment
      # This requires the paperclip gem, which has now been removed, so it is replaced by:
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
    end
  end

  def self.down
    drop_column :messages, :attachment_file_name
    drop_column :messages, :attachment_content_type
    drop_column :messages, :attachment_file_size
    drop_column :messages, :attachment_updated_at
  end
end
