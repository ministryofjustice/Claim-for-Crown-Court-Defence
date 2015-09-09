class AddFormIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :form_id, :string
  end
end
