class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.references :claim, index: true
      t.string :description
      t.string :document

      t.timestamps
    end
    add_index :documents, :description
  end
end
