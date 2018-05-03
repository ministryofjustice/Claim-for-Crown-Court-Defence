class AddFormIdToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :form_id, :string
  end
end
