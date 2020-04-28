class Claim::LitigatorHardshipClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    {
      case_details: %i[
        case_type
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

  def validate_case_type
    validate_presence(:case_type, 'case_type_blank')
    validate_inclusion(:case_type, @record.eligible_case_types, 'inclusion')
  end

  def validate_offence
    validate_presence(:offence, 'blank_class') unless fixed_fee_case?
  end
end
