class Claim::BaseClaimValidator < BaseValidator
  def self.mandatory_fields
    %i[
      external_user_id
      creator
      amount_assessed
      evidence_checklist_ids
    ]
  end

  private

  def validate_step_fields
    self.class.fields_for_steps[steps_range(@record)].flatten.each do |field|
      validate_field(field)
    end
  end

  def validate_field(field)
    __send__("validate_#{field}")
  end

  def validate_external_user_id
    return if @record.disable_for_state_transition.eql?(:only_amount_assessed)
    validate_presence(:external_user, "blank_#{@record.external_user_type}")
    validate_external_user_has_required_role unless @record.external_user.nil?
    return if @record.errors.key?(:external_user)
    validate_creator_and_external_user_have_same_provider
  end

  def validate_external_user_has_required_role
    validate_has_role(@record.external_user,
                      [@record.external_user_type, :admin],
                      :external_user,
                      "must have #{@record.external_user_type} role")
  end

  def validate_creator_and_external_user_have_same_provider
    return if @record.creator_id == @record.external_user_id ||
              @record.creator.try(:provider) == @record.external_user.try(:provider)
    @record.errors[:external_user] << "Creator and #{@record.external_user_type} must belong to the same provider"
  end

  def validate_total
    return if @record.source == 'api'

    validate_numericality(:total, 'numericality', 0.1, nil)
    validate_amount_less_than_claim_max(:total)
  end

  # ALWAYS required/mandatory
  def validate_creator
    return if @record.disable_for_state_transition.eql?(:only_amount_assessed)
    validate_presence(:creator, 'blank') unless @record.errors.key?(:creator)
  end

  # must be present
  def validate_case_type
    validate_presence(:case_type, 'blank')
  end

  # must be present
  def validate_court
    validate_presence(:court, 'blank')
  end

  # must be present
  # must have a format of capital letter followed by 8 digits
  def validate_case_number
    @record.case_number&.upcase!
    validate_presence(:case_number, 'blank')
    validate_pattern(:case_number, CASE_NUMBER_PATTERN, 'invalid')
  end

  def validate_transfer_court
    validate_presence(:transfer_court, 'blank') if @record.transfer_case_number.present?
    validate_exclusion(:transfer_court, [@record.court], 'same')
  end

  def validate_transfer_case_number
    validate_pattern(:transfer_case_number, CASE_NUMBER_PATTERN, 'invalid')
  end

  def validate_estimated_trial_length
    validate_trial_length(:estimated_trial_length)
  end

  def validate_actual_trial_length
    validate_trial_length(:actual_trial_length)
    validate_trial_actual_length_consistency
  end

  def validate_retrial_estimated_length
    validate_retrial_length(:retrial_estimated_length)
  end

  def validate_retrial_actual_length
    validate_retrial_length(:retrial_actual_length)
    validate_retrial_actual_length_consistency
  end

  # must be present if case type is cracked trial or cracked before retial
  # must be one of the list of values
  # must be final third if case type is cracked before retrial (cannot be first or second third)
  def validate_trial_cracked_at_third
    if cracked_case?
      validate_presence(:trial_cracked_at_third, 'blank')
      validate_inclusion(:trial_cracked_at_third, Settings.trial_cracked_at_third, 'invalid')
      if @record&.case_type&.name == 'Cracked before retrial'
        validate_pattern(:trial_cracked_at_third, /^final_third$/, 'invalid_case_type_third_combination')
      end
    end
  end

  def validate_amount_assessed
    case @record.state
    when 'authorised', 'part_authorised'
      if @record.assessment.blank?
        add_error(:amount_assessed, "Amount assessed cannot be zero for claims in state #{@record.state.humanize}")
      end
    when 'draft', 'refused', 'rejected', 'submitted'
      if @record.assessment.present?
        add_error(:amount_assessed, "Amount assessed must be zero for claims in state #{@record.state.humanize}")
      end
    end
  end

  def validate_evidence_checklist_ids
    return if @record.disable_for_state_transition.eql?(:only_amount_assessed)
    check_for_and_raise_array_error

    # prevent non-numeric array elements
    # NOTE: non-numeric strings/chars will yield a value of 0 and this is checked for to add an error
    @record.evidence_checklist_ids = @record.evidence_checklist_ids.select(&:present?).map(&:to_i)
    if @record.evidence_checklist_ids.include?(0)
      add_error(:evidence_checklist_ids,
                'Evidence checklist ids are of an invalid type or zero, please use valid Evidence checklist ids')
      return
    end
    check_array_elements
  end

  def check_array_elements
    # prevent array elements that do no represent a doctype
    @record.evidence_checklist_ids.each do |id|
      unless DocType.all.map(&:id).include?(id)
        add_error(:evidence_checklist_ids,
                  "Evidence checklist id #{id} is invalid, please use valid evidence checklist ids")
      end
    end
  end

  def check_for_and_raise_array_error
    unless @record.evidence_checklist_ids.is_a?(Array)
      raise ActiveRecord::SerializationTypeMismatch,
            "Attribute was supposed to be a Array, but was a #{@record.evidence_checklist_ids.class}."
    end
  end

  # required when case type is cracked, cracked before retrial
  # cannot be in the future
  # cannot be before earliest rep order
  # cannot be more than 5 years old
  def validate_trial_fixed_notice_at
    return unless @record.case_type && @record.requires_cracked_dates?
    validate_presence(:trial_fixed_notice_at, 'blank')
    validate_on_or_before(Date.today, :trial_fixed_notice_at, 'check_not_in_future')
    validate_too_far_in_past(:trial_fixed_notice_at)
    validate_before(@record.trial_fixed_at, :trial_fixed_notice_at, 'check_before_trial_fixed_at')
    validate_before(@record.trial_cracked_at, :trial_fixed_notice_at, 'check_before_trial_cracked_at')
  end

  # required when case type is cracked, cracked before retrieal
  # REMOVED as trial may never have occured - cannot be in the future
  # cannot be before earliest rep order
  # cannot be more than 5 years old
  # cannot be before trial_fixed_notice_at
  def validate_trial_fixed_at
    if @record.case_type && @record.requires_cracked_dates?
      validate_presence(:trial_fixed_at, 'blank')
      validate_too_far_in_past(:trial_fixed_at)
      validate_on_or_after(@record.trial_fixed_notice_at, :trial_fixed_at,
                           'check_not_earlier_than_trial_fixed_notice_at')
    end
  end

  # required when case type is cracked, cracked before retrial
  # cannot be in the future
  # cannot be before the rep order was granted
  # cannot be more than 5 years in the past
  # cannot be before the trial fixed/warned issued
  def validate_trial_cracked_at
    if @record.case_type && @record.requires_cracked_dates?
      validate_presence(:trial_cracked_at, 'blank')
      validate_on_or_before(Date.today, :trial_cracked_at, 'check_not_in_future')
      validate_too_far_in_past(:trial_cracked_at)
      validate_on_or_after(@record.trial_fixed_notice_at, :trial_cracked_at,
                           'check_not_earlier_than_trial_fixed_notice_at')
      validate_on_or_before(@record.trial_fixed_at, :trial_cracked_at, 'check_before_trial_fixed_at')
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
  # ---------------------------
  def method_missing(method, *args)
    if method.to_s =~ /^requires_(re){0,1}trial_dates\?/
      begin
        @record.case_type.__send__(method)
      rescue
        false
      end
    else
      super
    end
  end

  def validate_trial_length(field)
    return unless requires_trial_dates?
    validate_presence(field, 'blank')
    validate_numericality(field, 'invalid', 0, nil) unless @record.__send__(field).nil?
  end

  def validate_retrial_length(field)
    return unless requires_retrial_dates?
    # TODO: this condition is a temproary workaround for live data that existed prior to addition of retrial details
    validate_presence(field, 'blank') if @record.editable?
    validate_numericality(field, 'invalid', 0, nil) unless @record.__send__(field).nil?
  end

  def validate_trial_actual_length_consistency
    return unless actual_length_consistency_for_trial

    # As we are using Date objects without time information, we loose precision, so adding 1 day will workaround this.
    return unless ((@record.trial_concluded_at - @record.first_day_of_trial).days + 1.day) <
                  @record.actual_trial_length.days
    add_error(:actual_trial_length, 'too_long')
  end

  def actual_length_consistency_for_trial
    requires_trial_dates? &&
      @record.actual_trial_length.present? &&
      @record.first_day_of_trial.present? &&
      @record.trial_concluded_at.present?
  end

  def validate_retrial_actual_length_consistency
    return unless actual_length_consistency_for_retrial

    # As we are using Date objects without time information, we loose precision, so adding 1 day will workaround this.
    return unless ((@record.retrial_concluded_at - @record.retrial_started_at).days + 1.day) <
                  @record.retrial_actual_length.days
    add_error(:retrial_actual_length, 'too_long')
  end

  def cracked_case?
    @record.case_type.name.match(/[Cc]racked/)
  rescue
    false
  end

  def actual_length_consistency_for_retrial
    requires_retrial_dates? &&
      @record.retrial_actual_length.present? &&
      @record.retrial_started_at.present? &&
      @record.retrial_concluded_at.present?
  end

  def has_fees_or_expenses_attributes?
    (@record.fixed_fees.present? || @record.misc_fees.present?) ||
      (@record.basic_fees.present? || @record.expenses.present?)
  end

  def fixed_fee_case?
    @record.case_type.is_fixed_fee?
  rescue
    false
  end

  def snake_case_type
    @record.case_type.name.downcase.tr(' ', '_')
  end

  def earliest_rep_order
    @record.earliest_representation_order_date
  end

  def validate_trial_start_and_end(start_attribute, end_attribute, inverse = false)
    if @record.case_type && @record.case_type.requires_trial_dates?
      start_attribute, end_attribute = end_attribute, start_attribute if inverse
      validate_presence(start_attribute, 'blank')
      method("validate_on_or_#{inverse ? 'after' : 'before'}".to_sym)
        .call(@record.__send__(end_attribute), start_attribute, 'check_other_date')

      unless @record.case_type.requires_retrial_dates?
        validate_on_or_after(earliest_rep_order, start_attribute, 'check_not_earlier_than_rep_order')
      end
      validate_too_far_in_past(start_attribute)
    end
  end

  def validate_retrial_start_and_end(start_attribute, end_attribute, inverse = false)
    if @record.case_type && @record.case_type.requires_retrial_dates?
      start_attribute, end_attribute = end_attribute, start_attribute if inverse
      # TODO: this condition is a temproary workaround for live data that existed prior to addition of retrial details
      validate_presence(start_attribute, 'blank') if @record.editable?
      method("validate_on_or_#{inverse ? 'after' : 'before'}".to_sym)
        .call(@record.__send__(end_attribute), start_attribute, 'check_other_date')

      validate_on_or_after(earliest_rep_order, start_attribute, 'check_not_earlier_than_rep_order')
      validate_too_far_in_past(start_attribute)
    end
  end

  def validate_too_far_in_past(start_attribute)
    validate_on_or_after(Settings.earliest_permitted_date, start_attribute, 'check_not_too_far_in_past')
  end
end
