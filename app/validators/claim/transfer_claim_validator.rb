module Claim
  class TransferClaimValidator < BaseClaimValidator
    include Claim::LitigatorCommonValidations

    def self.fields_for_steps
      [
        [
          :case_type,
          :court,
          :case_number,
          :advocate_category,
          :offence,
          :case_concluded_at
        ],
        [
          :litigator_type,
          :elected_case,
          :transfer_stage_id,
          :transfer_date,
          :case_conclusion_id,
          :transfer_detail_combo
        ]
      ]
    end

    private

    def validate_litigator_type
      unless @record.litigator_type.in? %w{ new original }
        add_error(:litigator_type, 'invalid')
      end
    end

    def validate_elected_case
      unless @record.elected_case.in?([ true, false ])
        add_error(:elected_case, 'invalid')
      end
    end

    def validate_transfer_stage_id
      unless @record.transfer_stage_id.in? TransferBrain.transfer_stage_ids
        add_error(:transfer_stage_id, 'invalid')
      end
    end

    def validate_transfer_date
      validate_presence(:transfer_date, 'blank')
      validate_not_after(Date.today, :transfer_date, 'check_not_in_future')
      validate_not_before(Settings.earliest_permitted_date, :transfer_date, 'check_not_too_far_in_past')
    end

    def validate_case_conclusion_id
      if TransferBrain.case_conclusion_required?(@record.transfer_detail)
        validate_presence(:case_conclusion_id,'blank')
        validate_inclusion(:case_conclusion_id,TransferBrain.case_conclusion_ids,'invalid')
      else
        validate_absence(:case_conclusion_id,'present')
      end
    end

    def validate_transfer_detail_combo
      unless TransferBrain.details_combo_valid?(@record.transfer_detail)
        add_error(:transfer_detail, 'invalid_combo')
      end
    end

  end
end
