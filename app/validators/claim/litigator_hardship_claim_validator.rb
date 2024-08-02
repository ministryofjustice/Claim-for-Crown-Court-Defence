module Claim
  class LitigatorHardshipClaimValidator < Claim::BaseClaimValidator
    include Claim::LitigatorCommonValidations

    def self.fields_for_steps
      {
        case_details: %i[
          case_type_id
          case_stage_id
          court_id
          case_number
          london_rates_apply
          case_transferred_from_another_court
          transfer_court_id
          transfer_case_number
          main_hearing_date
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
      validate_absence(:case_type_id, :present)
    end

    def validate_case_stage_id
      validate_belongs_to_object_presence(:case_stage, :blank)
      validate_inclusion(:case_stage_id, @record.eligible_case_stages.pluck(:id), :inclusion)
    end

    def validate_offence
      validate_presence(:offence, :blank) unless fixed_fee_case?
    end
  end
end
