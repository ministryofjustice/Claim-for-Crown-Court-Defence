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

  private

  delegate :current_step, to: :@record

  # TODO: overide base claim validator method for now
  # but this needs to be promoted eventually
  def validate_step_fields
    self.class.fields_for_steps[current_step].flatten.each do |field|
      validate_field(field)
    end
  end
end
