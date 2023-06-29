module Claim
  class AdvocateSupplementaryClaimSubModelValidator < Claim::BaseClaimSubModelValidator
    def has_one_association_names_for_steps
      {
        case_details: [],
        defendants: []
      }
    end

    def has_many_association_names_for_steps
      {
        case_details: [],
        defendants: [{ name: :defendants, options: { presence: true } }],
        offence_details: [],
        miscellaneous_fees: [{ name: :misc_fees, options: { presence: true } }],
        travel_expenses: [{ name: :expenses }],
        supporting_evidence: [{ name: :documents }]
      }
    end
  end
end
