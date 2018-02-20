class Claim::LitigatorClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    {
      case_details: %i[
        case_type
        court
        case_number
        transfer_court
        transfer_case_number
        advocate_category
        case_concluded_at
      ],
      defendants: [],
      offence_details: %i[offence],
      graduated_fees: %i[actual_trial_length],
      additional_information: %i[total]
    }
  end

  private

  def step_fields_for_validation
    self.class.fields_for_steps.select do |k, _v|
      @record.submission_current_flow.map(&:to_sym).include?(k)
    end.values.flatten
  end
end
