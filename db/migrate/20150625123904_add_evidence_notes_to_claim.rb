class AddEvidenceNotesToClaim < ActiveRecord::Migration[4.2]
  def up
    add_column :claims, :evidence_notes, :text
    remove_column :documents, :notes
    remove_column :documents, :document_type_id
  end

  def down
    remove_column :claims, :evidence_notes
    add_column :documents, :notes, :text
    add_column :documents, :document_type_id, :integer
  end
end
