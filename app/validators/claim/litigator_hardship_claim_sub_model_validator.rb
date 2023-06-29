module Claim
  class LitigatorHardshipClaimSubModelValidator < Claim::BaseClaimSubModelValidator
    def has_one_association_names_for_steps
      {
        case_details: [],
        defendants: [],
        offence_details: [],
        hardship_fees: [{ name: :hardship_fee, options: { presence: true } }],
        miscellaneous_fees: []
      }
    end

    def has_many_association_names_for_steps
      {
        case_details: [],
        defendants: [{ name: :defendants, options: { presence: true } }],
        offence_details: [],
        miscellaneous_fees: [{ name: :misc_fees }],
        supporting_evidence: [{ name: :documents }]
      }
    end
  end
end
