class AddEvidenceChecklistToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :evidence_checklist_ids, :string
  end
end
