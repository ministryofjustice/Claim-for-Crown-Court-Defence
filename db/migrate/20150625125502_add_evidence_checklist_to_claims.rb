class AddEvidenceChecklistToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :evidence_checklist_ids, :string
  end
end
