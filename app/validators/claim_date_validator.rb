# class ClaimDateValidator < ActiveModel::Validator
class ClaimDateValidator < BaseClaimValidator

  @@fields = [
    :trial_fixed_notice_at,
    :trial_fixed_at,
    :trial_cracked_at,
    :first_day_of_trial,
    :trial_concluded_at
  ]

  def self.fields
    @@fields
  end


  private

  # required when case type is cracked, cracked before retrial
  # cannot be in the future
  # cannot be before earliest rep order
  # cannot be more than 5 years old
  def validate_trial_fixed_notice_at
    validate_presence(:trial_fixed_notice_at, "Please enter valid date notice of first fixed/warned issued") if @record.try(:case_type).try(:requires_cracked_dates?)
    validate_not_after(Date.today, :trial_fixed_notice_at, "Date notice of first fixed/warned issued may not be in the future")
    validate_not_before(Settings.earliest_permitted_date, :trial_fixed_notice_at, "Date notice of first fixed/warned issued may not be more than #{Settings.earliest_permitted_date_in_words}")
    validate_not_before(earliest_rep_order, :trial_fixed_notice_at, "Date notice of first fixed/warned issued may not be earlier than the first representation order date")
  end


  # required when case type is cracked, cracked before retrieal
  # cannot be in the future
  # cannot be before earliest rep order
  # cannot be more than 5 years old
  # cannot be before trial_fixed_notice_at
  def validate_trial_fixed_at
    validate_presence(:trial_fixed_at, "Please enter valid date first fixed/warned") if @record.try(:case_type).try(:requires_cracked_dates?)
    validate_not_after(Date.today, :trial_fixed_at, "Date first fixed/warned may not be in the future")
    validate_not_before(Settings.earliest_permitted_date, :trial_fixed_at, "Date first fixed/warned may not be more than #{Settings.earliest_permitted_date_in_words}")
    validate_not_before(earliest_rep_order, :trial_fixed_at, "Date first fixed/warned may not be earlier than the first representation order date")
    validate_not_before(@record.trial_fixed_notice_at, :trial_fixed_at, "Date first fixed/warned may not be earlier than the date notice of first fixed/warned issued")
  end

  # required when case type is cracked, cracked before retrial
  # cannot be in the future
  # cannot be before the rep order was granted
  # cannot be more than 5 years in the past
  # cannot be before the trial fixed/warned issued
  def validate_trial_cracked_at
    validate_presence(:trial_cracked_at, "Please enter valid date when case cracked") if @record.try(:case_type).try(:requires_cracked_dates?)
    validate_not_after(Date.today, :trial_cracked_at, "Date case cracked may not be in the future")
    validate_not_before(Settings.earliest_permitted_date, :trial_cracked_at, "Date case cracked may not be more than #{Settings.earliest_permitted_date_in_words}")
    validate_not_before(earliest_rep_order, :trial_cracked_at, "Date case cracked may not be earlier than the first representation order date")
    validate_not_before(@record.trial_fixed_notice_at, :trial_cracked_at, "Date case cracked may not be earlier than the date notice of first fixed/warned issued")
  end


  # cannot be in the future
  # must be less than or equal to last day of trial
  # cannot be before first rep order date
  # cannot be more than 5 years in the past
  def validate_first_day_of_trial
    validate_presence(:first_day_of_trial, "Please enter a valid date for first day of trial") if @record.try(:case_type).try(:requires_trial_dates?)
    validate_not_after(@record.trial_concluded_at, :first_day_of_trial, "First day of trial must not be after date trial concluded")
    validate_not_before(earliest_rep_order, :first_day_of_trial, "First day of trial must not be earlier than the first representation order date")
    validate_not_before(Settings.earliest_permitted_date, :first_day_of_trial, "First day of trial must not be more than #{Settings.earliest_permitted_date_in_words}")
  end


  # cannot be in the future
  # cannot be before the first day of trial
  # cannot be before the first rep order was granted
  # cannot be more than 5 years in sthe past
  def validate_trial_concluded_at
    validate_presence(:trial_concluded_at, "Please enter a valid date for date trial concluded") if @record.try(:case_type).try(:requires_trial_dates?)
    validate_not_after(@record.trial_concluded_at, :first_day_of_trial, "First day of trial must not be after date trial concluded")
    validate_not_before(@record.first_day_of_trial, :trial_concluded_at, "Date trial concluded must not be before first day of trial")
    validate_not_before(earliest_rep_order, :trial_concluded_at, "Date trial concluded must not be earlier than the first representation order date")
    validate_not_before(Settings.earliest_permitted_date, :trial_concluded_at, "Date trial concluded must not be more than #{Settings.earliest_permitted_date_in_words}")
  end



  

  def earliest_rep_order
    @record.try(:earliest_representation_order).try(:representation_order_date)
  end

end