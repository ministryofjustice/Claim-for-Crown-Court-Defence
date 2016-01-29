# class ClaimDateValidator < ActiveModel::Validator
class ClaimDateValidator < BaseClaimValidator

  def self.fields
    [
    :trial_fixed_notice_at,
    :trial_fixed_at,
    :trial_cracked_at,
    :first_day_of_trial,
    :trial_concluded_at,
    :retrial_started_at,
    :retrial_concluded_at
    ]
  end

  private

  def snake_case_type
    @record.case_type.name.downcase.gsub(' ', '_')
  end

  # required when case type is cracked, cracked before retrial
  # cannot be in the future
  # cannot be before earliest rep order
  # cannot be more than 5 years old
  def validate_trial_fixed_notice_at
    if @record.case_type  && @record.case_type.requires_cracked_dates?
      validate_presence(:trial_fixed_notice_at, "blank_#{snake_case_type}_date")
      validate_not_after(Date.today, :trial_fixed_notice_at, "check_#{snake_case_type}_date")
      validate_not_before(Settings.earliest_permitted_date, :trial_fixed_notice_at, "check_#{snake_case_type}_date")
      validate_not_before(earliest_rep_order, :trial_fixed_notice_at, "check_#{snake_case_type}_date")
    end
  end

  # required when case type is cracked, cracked before retrieal
  # REMOVED as trial may never have occured - cannot be in the future
  # cannot be before earliest rep order
  # cannot be more than 5 years old
  # cannot be before trial_fixed_notice_at
  def validate_trial_fixed_at
    if @record.case_type  && @record.case_type.requires_cracked_dates?
      validate_presence(:trial_fixed_at, "blank_#{snake_case_type}_date")
      validate_not_before(Settings.earliest_permitted_date, :trial_fixed_at, "check_#{snake_case_type}_date")
      validate_not_before(earliest_rep_order, :trial_fixed_at, "check_#{snake_case_type}_date")
      validate_not_before(@record.trial_fixed_notice_at, :trial_fixed_at, "check_#{snake_case_type}_date")
    end
  end

  # required when case type is cracked, cracked before retrial
  # cannot be in the future
  # cannot be before the rep order was granted
  # cannot be more than 5 years in the past
  # cannot be before the trial fixed/warned issued
  def validate_trial_cracked_at
    if @record.case_type && @record.case_type.requires_cracked_dates?
      validate_presence(:trial_cracked_at, "blank_#{snake_case_type}_date")
      validate_not_after(Date.today, :trial_cracked_at, "check_#{snake_case_type}_date")
      validate_not_before(Settings.earliest_permitted_date, :trial_cracked_at, "check_#{snake_case_type}_date")
      validate_not_before(earliest_rep_order, :trial_cracked_at, "check_#{snake_case_type}_date")
      validate_not_before(@record.trial_fixed_notice_at, :trial_cracked_at, "check_#{snake_case_type}_date")
    end
  end

  # must be less than or equal to last day of trial
  # cannot be before first rep order date (except for retrials)
  # cannot be more than 5 years in the past
  def validate_first_day_of_trial
    validate_trial_start_and_end(:first_day_of_trial, :trial_concluded_at, false)
  end

  # cannot be before the first day of trial
  # cannot be before the first rep order was granted
  # cannot be more than 5 years in sthe past
  def validate_trial_concluded_at
    validate_trial_start_and_end(:first_day_of_trial, :trial_concluded_at, true)
  end

  # must exist for retrial claims
  # must be less than or equal to last day of retrial
  # cannot be before earliest rep order date
  # cannot be more than 5 years in the past
  def validate_retrial_started_at
    validate_retrial_start_and_end(:retrial_started_at, :retrial_concluded_at, false)
  end

  # cannot be before the first day of retrial
  # cannot be before the first rep order was granted
  # cannot be more than 5 years in the past
  def validate_retrial_concluded_at
    validate_retrial_start_and_end(:retrial_started_at, :retrial_concluded_at, true)
  end

  # local helpers
  # ---------------
  def earliest_rep_order
    @record.try(:earliest_representation_order).try(:representation_order_date)
  end

  def validate_trial_start_and_end(start_attribute, end_attribute, inverse=false)
    if @record.case_type && @record.case_type.requires_trial_dates?
      start_attribute, end_attribute = end_attribute, start_attribute if inverse
      validate_presence(start_attribute, "blank")
      method("validate_not_#{inverse ? 'before' : 'after' }".to_sym).call(@record.__send__(end_attribute), start_attribute, "blank")
      validate_not_before(earliest_rep_order, start_attribute, "blank") unless @record.case_type.requires_retrial_dates?
      validate_not_before(Settings.earliest_permitted_date, start_attribute, "blank")
    end
  end

  def validate_retrial_start_and_end(start_attribute, end_attribute, inverse=false)
    if @record.case_type && @record.case_type.requires_retrial_dates?
      start_attribute, end_attribute = end_attribute, start_attribute if inverse
      validate_presence(start_attribute, "blank")
      method("validate_not_#{inverse ? 'before' : 'after' }".to_sym).call(@record.__send__(end_attribute), start_attribute, "blank")
      validate_not_before(earliest_rep_order, start_attribute, "blank")
      validate_not_before(Settings.earliest_permitted_date, start_attribute, "blank")
    end
  end

end