class AddAuthorAndSubjectToClaimStateTransitions < ActiveRecord::Migration
  def change
    add_column :claim_state_transitions, :author_id, :integer
    add_column :claim_state_transitions, :subject_id, :integer
  end
end
