class DropPaperclipFieldsFromDocuments < ActiveRecord::Migration[6.1]
  def change
    remove_index :documents, :document_file_name, name: :index_documents_on_document_file_name

    remove_column :documents, :as_converted_preview_document_checksum, :string
    remove_column :documents, :converted_preview_document_updated_at, :datetime
    remove_column :documents, :converted_preview_document_file_size, :integer
    remove_column :documents, :converted_preview_document_content_type, :string
    remove_column :documents, :converted_preview_document_file_name, :string
    remove_column :documents, :as_document_checksum, :string
    remove_column :documents, :document_updated_at, :datetime
    remove_column :documents, :document_file_size, :integer
    remove_column :documents, :document_content_type, :string
    remove_column :documents, :document_file_name, :string
  end
end
