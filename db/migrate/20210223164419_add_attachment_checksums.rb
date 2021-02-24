class AddAttachmentChecksums < ActiveRecord::Migration[6.0]
  def change
    add_column :stats_reports, :as_document_checksum, :string
    add_column :messages, :as_attachment_checksum, :string
    add_column :documents, :as_document_checksum, :string
    add_column :documents, :as_converted_preview_document_checksum, :string
  end
end
