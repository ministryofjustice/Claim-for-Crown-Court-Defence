class Claim::AdvocateHardshipClaimValidator < Claim::BaseClaimValidator
  include Claim::AdvocateClaimCommonValidations
  include Claim::DefendantUpliftValidations

  def self.fields_for_steps
    {
      case_details: %i[
        case_type
        court
        case_number
        case_transferred_from_another_court
        transfer_court
        transfer_case_number
        trial_details
        retrial_details
        trial_cracked_at_third
        trial_fixed_notice_at
        trial_fixed_at
        trial_cracked_at
        supplier_number
      ],
      defendants: [],
      offence_details: %i[offence],
      basic_fees: FEE_VALIDATION_FIELDS + %i[
        advocate_category defendant_uplifts_basic_fees
      ],
      miscellaneous_fees: %i[defendant_uplifts_misc_fees],
      travel_expenses: %i[travel_expense_additional_information],
      supporting_evidence: []
    }
  end

  FEE_VALIDATION_FIELDS = %i[total].freeze

  private

  def validate_case_type
    validate_presence(:case_type, 'blank')
    validate_inclusion(:case_type, @record.eligible_case_types, 'inclusion')
  end

  def validate_offence
    error_message = @record.agfs_reform? ? 'new_blank' : 'blank'
    validate_presence(:offence, error_message)
  end

  def validate_trial_details
    return unless @record&.case_type&.requires_trial_dates?

    validate_presence(:estimated_trial_length, 'blank')
    validate_numericality(:estimated_trial_length, 'hardship_invalid', 0, nil)
    validate_presence(:first_day_of_trial, 'blank')
    validate_too_far_in_past(:first_day_of_trial)
    validate_on_or_before(Date.today, :first_day_of_trial, 'check_not_in_future')
    validate_on_or_before(@record.trial_concluded_at, :first_day_of_trial, 'check_other_date')
    validate_on_or_after(@record.first_day_of_trial, :trial_concluded_at, 'check_other_date')
    validate_on_or_after(earliest_rep_order, :first_day_of_trial, 'check_not_earlier_than_rep_order')
  end

  def validate_retrial_details
    return unless @record&.case_type&.requires_retrial_dates?

    # a retrial should have all trial details
    validate_trial_start_and_end(:first_day_of_trial, :trial_concluded_at, false)
    validate_trial_start_and_end(:first_day_of_trial, :trial_concluded_at, true)
    validate_presence(:estimated_trial_length, 'blank')
    validate_numericality(:estimated_trial_length, 'invalid', 0, nil)
    validate_presence(:actual_trial_length, 'blank')
    validate_numericality(:actual_trial_length, 'invalid', 0, nil)
    validate_trial_actual_length_consistency

    # plus minimum retrial started
    validate_presence(:retrial_estimated_length, 'blank')
    validate_numericality(:retrial_estimated_length, 'invalid', 0, nil)
    validate_presence(:retrial_started_at, 'blank')
    validate_too_far_in_past(:retrial_started_at)
    validate_on_or_before(Date.today, :retrial_started_at, 'check_not_in_future')
    validate_on_or_after(@record.trial_concluded_at, :retrial_started_at, 'check_not_earlier_than_trial_concluded')
    validate_on_or_after(@record.retrial_started_at, :retrial_concluded_at, 'check_other_date')
    validate_on_or_before(@record.retrial_concluded_at, :retrial_started_at, 'check_other_date')
    validate_on_or_after(earliest_rep_order, :retrial_started_at, 'check_not_earlier_than_rep_order')
  end

  def validate_trial_actual_length_consistency
    return unless actual_length_consistent?(true,
                                            @record.actual_trial_length,
                                            @record.first_day_of_trial,
                                            @record.trial_concluded_at)
    add_error(:actual_trial_length, 'too_long')
  end
end
