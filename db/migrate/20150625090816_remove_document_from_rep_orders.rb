class RemoveDocumentFromRepOrders < ActiveRecord::Migration[4.2]

  def up
    remove_column :representation_orders, :document_file_name
    remove_column :representation_orders, :document_content_type
    remove_column :representation_orders, :document_file_size
    remove_column :representation_orders, :document_updated_at
    remove_column :representation_orders, :converted_preview_document_file_name
    remove_column :representation_orders, :converted_preview_document_content_type
    remove_column :representation_orders, :converted_preview_document_file_size
    remove_column :representation_orders, :converted_preview_document_updated_at
  end

  def down
    add_column :representation_orders, :document_file_name, :string
    add_column :representation_orders, :document_content_type, :string
    add_column :representation_orders, :document_file_size, :integer
    add_column :representation_orders, :document_updated_at, :datetime
    add_column :representation_orders, :converted_preview_document_file_name, :string
    add_column :representation_orders, :converted_preview_document_content_type, :string
    add_column :representation_orders, :converted_preview_document_file_size, :integer
    add_column :representation_orders, :converted_preview_document_updated_at, :datetime
  end
end


