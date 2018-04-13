class CreateRepresentationOrders < ActiveRecord::Migration
  def change
    create_table :representation_orders do |t|
      t.integer   :defendant_id
      t.string    :document_file_name
      t.string    :document_content_type
      t.integer   :document_file_size
      t.datetime  :document_updated_at
      t.string    :converted_preview_document_file_name
      t.string    :converted_preview_document_content_type
      t.integer   :converted_preview_document_file_size
      t.datetime  :converted_preview_document_updated_at

      t.timestamps null: true
    end
  end
end

