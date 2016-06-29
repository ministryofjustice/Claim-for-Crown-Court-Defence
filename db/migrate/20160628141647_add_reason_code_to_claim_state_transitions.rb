class AddReasonCodeToClaimStateTransitions < ActiveRecord::Migration
  def change
    add_column :claim_state_transitions, :reason_code, :string
  end
end
