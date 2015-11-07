# class ClaimDateValidator < ActiveModel::Validator
class ClaimDateValidator < BaseClaimValidator

  def self.fields
    [
    :trial_fixed_notice_at,
    :trial_fixed_at,
    :trial_cracked_at,
    :first_day_of_trial,
    :trial_concluded_at
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
  # cannot be in the future
  # cannot be before earliest rep order
  # cannot be more than 5 years old
  # cannot be before trial_fixed_notice_at
  def validate_trial_fixed_at
    if @record.case_type  && @record.case_type.requires_cracked_dates?
      validate_presence(:trial_fixed_at, "blank_#{snake_case_type}_date") 
      validate_not_after(Date.today, :trial_fixed_at, "check_#{snake_case_type}_date")
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

  # cannot be in the future
  # must be less than or equal to last day of trial
  # cannot be before first rep order date
  # cannot be more than 5 years in the past
  def validate_first_day_of_trial
    if @record.case_type && @record.case_type.requires_trial_dates? 
      validate_presence(:first_day_of_trial, "blank") 
      validate_not_after(@record.trial_concluded_at, :first_day_of_trial, "blank")
      validate_not_before(earliest_rep_order, :first_day_of_trial, "blank")
      validate_not_before(Settings.earliest_permitted_date, :first_day_of_trial, "blank")
    end
  end

  # cannot be in the future
  # cannot be before the first day of trial
  # cannot be before the first rep order was granted
  # cannot be more than 5 years in sthe past
  def validate_trial_concluded_at
    if @record.case_type && @record.case_type.requires_trial_dates? 
      validate_presence(:trial_concluded_at, "blank")
      validate_not_before(@record.first_day_of_trial, :trial_concluded_at, "blank")
      validate_not_before(earliest_rep_order, :trial_concluded_at, "blank")
      validate_not_before(Settings.earliest_permitted_date, :trial_concluded_at, "blank")
    end
  end

  def earliest_rep_order
    @record.try(:earliest_representation_order).try(:representation_order_date)
  end

end