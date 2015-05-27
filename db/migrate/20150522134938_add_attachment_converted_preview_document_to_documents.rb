class AddAttachmentConvertedPreviewDocumentToDocuments < ActiveRecord::Migration
  def self.up
    change_table :documents do |t|
      t.attachment :converted_preview_document
    end
  end

  def self.down
    remove_attachment :documents, :converted_preview_document
  end
end
