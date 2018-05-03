class AlterDocumentsAddPaperclipAttachement < ActiveRecord::Migration[4.2]
  def change
    change_table(:documents) do |t|
      t.remove      :document
      t.attachment  :document
    end
    add_index :documents, :document_file_name
  end
end
