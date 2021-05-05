class AlterDocumentsAddPaperclipAttachement < ActiveRecord::Migration[4.2]
  def change
    change_table(:documents) do |t|
      t.remove :document
      # Paperclip attachment are created using:
      #   t.attachment :document
      # This requires the paperclip gem, which has now been removed, so it is replaced by:
      t.string :document_file_name
      t.string :document_content_type
      t.integer :document_file_size
      t.datetime :document_updated_at
    end
    add_index :documents, :document_file_name
  end
end
