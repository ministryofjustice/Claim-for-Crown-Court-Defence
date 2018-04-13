class CreateDocumentTypes < ActiveRecord::Migration
  def change
    create_table :document_types do |t|
      t.string :description

      t.timestamps null: true
    end
  end
end
