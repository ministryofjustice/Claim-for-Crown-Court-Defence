module Claim
  class TransferClaimValidator < Claim::BaseClaimValidator
    include Claim::LitigatorCommonValidations

    # This defines all the fields that have to be validated in all cases
    def self.mandatory_fields
      %i[
        external_user_id
        creator
      ]
    end

    def self.fields_for_steps
      {
        transfer_fee_details: %i[
          litigator_type
          elected_case
          transfer_stage_id
          transfer_date
          case_conclusion_id
        ],
        case_details: %i[
          court_id
          case_number
          case_transferred_from_another_court
          transfer_court_id
          transfer_case_number
          case_concluded_at
          supplier_number
          amount_assessed
          evidence_checklist_ids
          main_hearing_date
        ],
        defendants: [],
        offence_details: %i[offence],
        transfer_fees: %i[transfer_fee total],
        travel_expenses: %i[travel_expense_additional_information],
        supporting_evidence: []
      }
    end

    private

    def validate_transfer_fee
      return if @record.from_api?
      add_error(:transfer_fee, 'blank') if @record.transfer_fee.nil?
    end

    def validate_litigator_type
      return if @record.litigator_type.in? %w[new original]
      add_error(:litigator_type, :invalid)
    end

    def validate_elected_case
      return if @record.elected_case.in?([true, false])
      add_error(:elected_case, :invalid)
    end

    def validate_transfer_stage_id
      return if @record.transfer_stage_id.in? Claim::TransferBrain.transfer_stage_ids
      add_error(:transfer_stage_id, :invalid)
    end

    def validate_transfer_date
      validate_presence(:transfer_date, :blank)
      validate_not_in_future(:transfer_date)
      validate_on_or_after(Settings.earliest_permitted_date, :transfer_date, :check_not_too_far_in_past)
    end

    def validate_case_conclusion_id
      if Claim::TransferBrain.case_conclusion_required?(@record.transfer_detail)
        validate_presence(:case_conclusion_id, :blank)
        validate_inclusion(:case_conclusion_id, Claim::TransferBrain.case_conclusion_ids, :invalid)
      else
        validate_absence(:case_conclusion_id, :present)
      end
    end
  end
end
