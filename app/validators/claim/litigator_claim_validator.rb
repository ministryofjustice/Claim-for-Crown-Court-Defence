class Claim::LitigatorClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    {
      case_details: [].unshift(first_step_common_validations),
      defendants: [],
      offence: %i[
        offence
      ],
      fixed_fees: [],
      graduated_fees: [],
      misc_fees: [],
      disbursements: [],
      warrant_fee: [],
      expenses: %i[
        total
      ],
      supporting_evidence: [],
      additional_information: [],
      other: []
    }.with_indifferent_access
  end
end
