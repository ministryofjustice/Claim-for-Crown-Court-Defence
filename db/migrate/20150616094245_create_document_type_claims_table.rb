class CreateDocumentTypeClaimsTable < ActiveRecord::Migration
   def change
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
