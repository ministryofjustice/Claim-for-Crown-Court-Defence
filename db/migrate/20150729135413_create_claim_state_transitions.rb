class CreateClaimStateTransitions < ActiveRecord::Migration
  def change
    create_table :claim_state_transitions do |t|
      t.references :claim, index: true
      t.string :namespace
      t.string :event
      t.string :from
      t.string :to
      t.timestamp :created_at
    end
  end
end
