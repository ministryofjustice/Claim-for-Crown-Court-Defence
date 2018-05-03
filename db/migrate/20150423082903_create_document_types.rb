class CreateDocumentTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :document_types do |t|
      t.string :description

      t.timestamps null: true
    end
  end
end
