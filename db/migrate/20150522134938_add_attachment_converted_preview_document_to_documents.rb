class AddAttachmentConvertedPreviewDocumentToDocuments < ActiveRecord::Migration[4.2]
  def self.up
    change_table :documents do |t|
      # Paperclip attachment are created using:
      #   t.attachment :converted_preview_document
      # This requires the paperclip gem, which has now been removed, so it is replaced by:
      t.string :converted_preview_document_file_name
      t.string :converted_preview_document_content_type
      t.integer :converted_preview_document_file_size
      t.datetime :converted_preview_document_updated_at
    end
  end

  def self.down
    drop_column :documents, :converted_preview_document_file_name
    drop_column :documents, :converted_preview_document_content_type
    drop_column :documents, :converted_preview_document_file_size
    drop_column :documents, :converted_preview_document_updated_at
  end
end
