class DropDocumentTypes < ActiveRecord::Migration[4.2]
  def up
    drop_table :document_types
    drop_table :document_type_claims
  end


  def down
    create_table :document_types do |t|
      t.string :description
      t.timestamps null: true
    end

    create_table :document_type_claims do |t|
      t.belongs_to :claim, null: false, index: true
      t.belongs_to :document_type, null: false, index: true

      t.timestamps null: true
    end

    add_index :document_type_claims,
              [:claim_id,:document_type_id],
              unique: true,
              name: 'document_type_claims_claim_id_document_type_id'
  end
end
