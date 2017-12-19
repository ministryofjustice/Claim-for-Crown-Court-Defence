class AddReasonTextToClaimStateTransition < ActiveRecord::Migration
  def change
    add_column :claim_state_transitions, :reason_text, :string
  end
end
