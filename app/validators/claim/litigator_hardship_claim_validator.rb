class Claim::LitigatorHardshipClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    {
      case_details: %i[
        case_type_id
        case_stage
        court
        case_number
        case_transferred_from_another_court
        transfer_court
        transfer_case_number
      ],
      defendants: [],
      offence_details: %i[offence],
      miscellaneous_fees: [],
      supporting_evidence: []
    }
  end

  private

  # NOTE**: case_type is delegated to case_stage for hardship claims
  # and should not exist directly on the claim
  def validate_case_type_id
    validate_absence(:case_type_id, 'present')
  end

  def validate_case_stage
    validate_presence(:case_stage, 'blank')
    validate_inclusion(:case_stage, @record.eligible_case_stages, 'inclusion')
  end

  def validate_offence
    validate_presence(:offence, 'blank_class') unless fixed_fee_case?
  end
end
