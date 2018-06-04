class CreateInterimClaimInfo < ActiveRecord::Migration[5.0]
  def change
    # NOTE: I'm being deliberaly pedantic about the name of the table here
    # to express exactly what it contains.
    #
    # This table stands as an interim (pun not included!) solution to what we
    # really should have which is well establish relationships between different types
    # of claims (e.g. interim/final)
    # Unfortunately, the requirements to determine how those relationships should be
    # established are not yet defined :S
    create_table :interim_claim_info do |t|
      t.boolean :warrant_fee_paid
      t.date :warrant_issued_date
      t.date :warrant_executed_date
      t.references :claim
    end
  end
end
