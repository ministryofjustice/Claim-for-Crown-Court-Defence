class DropPaperclipFieldsFromMessages < ActiveRecord::Migration[6.1]
  def change
    remove_column :messages, :as_attachment_checksum, :string
    remove_column :messages, :attachment_updated_at, :datetime
    remove_column :messages, :attachment_file_size, :integer
    remove_column :messages, :attachment_content_type, :string
    remove_column :messages, :attachment_file_name, :string
  end
end
