class AddReasonCodeToClaimStateTransitions < ActiveRecord::Migration[4.2]
  def change
    add_column :claim_state_transitions, :reason_code, :string
  end
end
