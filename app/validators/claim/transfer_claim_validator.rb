module Claim
  class TransferClaimValidator < BaseClaimValidator
    include Claim::LitigatorCommonValidations

    def self.fields_for_steps
      [
        [
          :case_type,
          :court,
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
          :transfer_detail_combo,
          :first_day_of_trial,
          # :estimated_trial_length,
          :trial_concluded_at,
          # :retrial_started_at,
          # :retrial_estimated_length,
          # :effective_pcmh_date,
          # :legal_aid_transfer_date,
          # :total
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
      validate_not_after(Date.today, :transfer_date, 'future')
      validate_not_before(Settings.earliest_permitted_date, :transfer_date, 'too_far_in_past')
    end

    def validate_case_conclusion_id
      return if @record.case_conclusion_id.nil?
      unless @record.case_conclusion_id.in? TransferBrain.case_conclusion_ids
        add_error(:case_conclusion_id, 'invalid')
      end
    end

    def validate_transfer_detail_combo
      unless TransferBrain.details_combo_valid?(@record.transfer_detail)
        add_error(:transfer_detail, 'invalid_combo')
      end
    end

    # def validate_first_day_of_trial
    #   validate_presence(:first_day_of_trial, 'blank') if requires_trial_dates?
    # end

    # def validate_trial_concluded_at
    #   validate_presence(:trial_concluded_at, 'blank') if requires_trial_dates?
    # end
    #
    # def validate_retrial_started_at
    #   validate_presence(:retrial_started_at, 'blank') if requires_trial_dates?
    # end

    def validate_effective_pcmh_date
      validate_presence(:effective_pcmh_date, 'blank') if @record.interim_fee.try(:is_effective_pcmh?)
    end

    def validate_legal_aid_transfer_date
      validate_presence(:effective_pcmh_date, 'blank') if @record.interim_fee.try(:is_retrial_new_solicitor?)
    end
  end
end
