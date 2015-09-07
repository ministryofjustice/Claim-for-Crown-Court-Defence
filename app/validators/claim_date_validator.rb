# class ClaimDateValidator < ActiveModel::Validator
class ClaimDateValidator < BaseClaimValidator

  @@claim_date_validator_fields = [ 
    :trial_fixed_notice_at, 
    :trial_fixed_at,
    :trial_cracked_at
  ]
 

  private

  # required when case type is cracked, cracked before retrial
  # cannot be in the future
  # cannot be before earliest rep order
  # cannot be more than 5 years old
  def validate_trial_fixed_notice_at
    validate_presence(:trial_fixed_notice_at, "Please enter valid date notice of first fixed/warned issued") if case_type_in("Cracked Trial", "Cracked before retrial")
    validate_not_after(Date.today, :trial_fixed_notice_at, "Date notice of first fixed/warned issued may not be in the future")
    validate_not_before(5.years.ago, :trial_fixed_notice_at, "Date notice of first fixed/warned issued may not be older than 5 years")
    validate_not_before(earliest_rep_order, :trial_fixed_notice_at, "Date notice of first fixed/warned issued may not be earlier than the first representation order date")
  end


  # required when case type is cracked, cracked before retrieal
  # cannot be in the future
  # cannot be before earliest rep order
  # cannot be more than 5 years old
  # cannot be before trial_fixed_notice_at
  def validate_trial_fixed_at
    validate_presence(:trial_fixed_at, "Please enter valid date first fixed/warned") if case_type_in("Cracked Trial", "Cracked before retrial")
    validate_not_after(Date.today, :trial_fixed_at, "Date first fixed/warned may not be in the future")
    validate_not_before(5.years.ago, :trial_fixed_at, "Date first fixed/warned may not be older than 5 years")
    validate_not_before(earliest_rep_order, :trial_fixed_at, "Date first fixed/warned may not be earlier than the first representation order date")
    validate_not_before(@record.trial_fixed_notice_at, :trial_fixed_at, "Date first fixed/warned may not be earlier than the date notice of first fixed/warned issued")
  end

  # required when case type is cracked, cracked before retrial
  # cannot be in the future
  # cannot be before the rep order was granted
  # cannot be more than 5 years in the past
  # cannot be before the trial fixed/warned issued
  def validate_trial_cracked_at
    validate_presence(:trial_cracked_at, "Please enter valid date when case cracked") if case_type_in("Cracked Trial", "Cracked before retrial")
    validate_not_after(Date.today, :trial_cracked_at, "Date case cracked may not be in the future")
    validate_not_before(5.years.ago, :trial_cracked_at, "Date case cracked may not be older than 5 years")
    validate_not_before(earliest_rep_order, :trial_cracked_at, "Date case cracked may not be earlier than the first representation order date")
    validate_not_before(@record.trial_fixed_notice_at, :trial_cracked_at, "Date case cracked may not be earlier than the date notice of first fixed/warned issued")
  end




  def validate_not_after(date, attribute, message)
    return if @record.send(attribute).nil? || date.nil?
    add_error(attribute, message) if @record.send(attribute) > date
  end

  def validate_not_before(date, attribute, message)
    return if @record.send(attribute).nil? || date.nil?
    add_error(attribute, message) if @record.send(attribute) < date
  end

  def case_type_in(*case_types)
    return false if @record.case_type.nil?
    case_types.include?(@record.case_type.name)
  end

  def earliest_rep_order
    @record.try(:earliest_representation_order).try(:representation_order_date)
  end

end