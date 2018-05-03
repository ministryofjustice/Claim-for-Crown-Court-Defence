class AddAuthorAndSubjectToClaimStateTransitions < ActiveRecord::Migration[4.2]
  def change
    add_column :claim_state_transitions, :author_id, :integer
    add_column :claim_state_transitions, :subject_id, :integer
  end
end
