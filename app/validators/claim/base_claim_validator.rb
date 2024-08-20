module Claim
  class BaseClaimValidator < BaseValidator
    def self.mandatory_fields
      %i[external_user_id creator amount_assessed evidence_checklist_ids earliest_representation_order_date]
    end

    private

    def step_fields_for_validation
      # NOTE: keeping existent validation for API purposes
      # The form validations just validate the fields for the current step
      return self.class.fields_for_steps[@record.form_step] || [] unless @record.from_api? || @record.form_step.nil?
      return self.class.fields_for_steps.values.flatten if !@record.from_api? && @record.form_step.nil?
      self.class.fields_for_steps.select do |k, _v|
        @record.submission_current_flow.map(&:to_sym).include?(k)
      end.values.flatten
    end

    def validate_step_fields
      step_fields_for_validation.each do |field|
        validate_field(field)
      end
    end

    def validate_field(field)
      __send__(:"validate_#{field}")
    end

    def validate_external_user_id
      return if @record.disable_for_state_transition.eql?(:only_amount_assessed)
      validate_belongs_to_object_presence(:external_user, :"blank_#{@record.external_user_type}")
      validate_external_user_has_required_role unless @record.external_user.nil?
      return if @record.errors.key?(:external_user_id)
      validate_creator_and_external_user_have_same_provider
    end

    def validate_external_user_has_required_role
      validate_has_role(@record.external_user,
                        [@record.external_user_type, :admin],
                        :external_user_id,
                        "must have #{@record.external_user_type} role")
    end

    def validate_creator_and_external_user_have_same_provider
      return if @record.creator_id == @record.external_user_id ||
                @record.creator.try(:provider) == @record.external_user.try(:provider)
      @record.errors.add(:external_user_id, "Creator and #{@record.external_user_type} must belong to the same provider")
    end

    def validate_total
      return if @record.from_api?

      validate_numericality(:total, 'numericality', 0.1, nil)
      validate_amount_less_than_claim_max(:total)
    end

    # ALWAYS required/mandatory
    def validate_creator
      return if @record.disable_for_state_transition.eql?(:only_amount_assessed)
      validate_presence(:creator, 'blank') unless @record.errors.key?(:creator)
    end

    # optional, must be boolean if present
    def validate_london_rates_apply
      validate_optional_boolean(:london_rates_apply, :not_boolean_or_nil)
    end

    # object must be present
    def validate_case_type_id
      validate_belongs_to_object_presence(:case_type, :blank)
    end

    # must be present
    def validate_court_id
      validate_belongs_to_object_presence(:court, :blank)
    end

    # must be present
    # must have a format of capital letter followed by 8 digits
    def validate_case_number
      @record.case_number&.upcase!
      validate_presence(:case_number, :blank)
      validate_pattern(:case_number, CASE_URN_PATTERN, :invalid_case_number_or_urn_format)
      return unless looks_like_a_case_number?(:case_number)

      validate_pattern(:case_number, CASE_NUMBER_PATTERN, :invalid_case_number_format)
    end

    def validate_case_transferred_from_another_court
      return unless @record.case_transferred_from_another_court
      validate_transfer_court_id(force: true)
      validate_transfer_case_number
    end

    def validate_transfer_court_id(force: false)
      return if @record.errors[:transfer_court_id].present?
      validate_belongs_to_object_presence(:transfer_court, :blank) if @record.transfer_case_number.present? || force
      validate_exclusion(:transfer_court_id, [@record.court_id], :same)
    end

    def validate_transfer_case_number
      return if @record.errors[:transfer_case_number].present?
      validate_pattern(:transfer_case_number, CASE_URN_PATTERN, :invalid_case_number_or_urn)
      return unless looks_like_a_case_number?(:transfer_case_number)

      validate_pattern(:transfer_case_number, CASE_NUMBER_PATTERN, :invalid)
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
      return unless cracked_case?
      validate_presence(:trial_cracked_at_third, :blank)
      validate_inclusion(:trial_cracked_at_third, Settings.trial_cracked_at_third, :invalid)
      return unless @record&.case_type&.name == 'Cracked before retrial'
      validate_pattern(:trial_cracked_at_third, /^final_third$/, :invalid_case_type_third_combination)
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
        unless @record.eligible_document_types.map(&:id).include?(id)
          add_error(:evidence_checklist_ids,
                    "Evidence checklist id #{id} is invalid, please use valid evidence checklist ids")
        end
      end
    end

    def check_for_and_raise_array_error
      return if @record.evidence_checklist_ids.is_a?(Array)
      raise ActiveRecord::SerializationTypeMismatch,
            "Attribute was supposed to be a Array, but was a #{@record.evidence_checklist_ids.class}."
    end

    # required when case type is cracked, cracked before retrial
    # cannot be in the future
    # cannot be before earliest rep order
    # cannot be more than 5 years old
    # must be 2+ days before trial_fixed_notice_at
    def validate_trial_fixed_notice_at
      return unless @record.case_type && @record.requires_cracked_dates?
      validate_presence(:trial_fixed_notice_at, :blank)
      validate_not_in_future(:trial_fixed_notice_at)
      validate_presence(:trial_fixed_notice_at, :blank)
      validate_too_far_in_past(:trial_fixed_notice_at)
      validate_before(@record.trial_fixed_at&.ago(1.day), :trial_fixed_notice_at, :check_before_trial_fixed_at)
      validate_before(@record.trial_cracked_at, :trial_fixed_notice_at, :check_before_trial_cracked_at)
    end

    # required when case type is cracked, cracked before retrieal
    # REMOVED as trial may never have occured - cannot be in the future
    # cannot be before earliest rep order
    # cannot be more than 5 years old
    # must be 2+ days after trial_fixed_at
    def validate_trial_fixed_at
      return if ignore_validation_for_cracked_trials?
      validate_presence(:trial_fixed_at, :blank)
      validate_too_far_in_past(:trial_fixed_at)
      validate_on_or_after(
        @record.trial_fixed_notice_at&.in(2.days),
        :trial_fixed_at,
        :check_after_trial_fixed_notice_at
      )
    end

    # required when case type is cracked, cracked before retrial
    # cannot be in the future
    # cannot be before the rep order was granted
    # cannot be more than 5 years in the past
    # cannot be before the trial fixed/warned issued
    def validate_trial_cracked_at
      return if ignore_validation_for_cracked_trials?
      validate_presence(:trial_cracked_at, :blank)
      validate_not_in_future(:trial_cracked_at)
      validate_too_far_in_past(:trial_cracked_at)
      validate_on_or_after(@record.trial_fixed_notice_at, :trial_cracked_at, :check_after_trial_fixed_notice_at)
    end

    def ignore_validation_for_cracked_trials?
      @record.disable_for_state_transition.eql?(:only_amount_assessed) ||
        @record.case_type.blank? ||
        (@record.case_type && !@record.requires_cracked_dates?)
    end

    def validate_trial_dates
      return unless @record&.requires_trial_dates?
      validate_trial_start_and_end(:first_day_of_trial, :trial_concluded_at, inverse: false)
      validate_trial_start_and_end(:first_day_of_trial, :trial_concluded_at, inverse: true)

      return if @record&.requires_retrial_dates?
      error_code = 'check_not_earlier_than_rep_order'
      validate_on_or_after(earliest_rep_order, :first_day_of_trial, error_code)
      return if @record.errors[:first_day_of_trial]&.include?(error_code)
      validate_on_or_after(earliest_rep_order, :trial_concluded_at, error_code)
    end

    # must exist for retrial claims
    # must be less than or equal to last day of retrial
    # cannot be before earliest rep order date
    # cannot be more than 5 years in the past
    def validate_retrial_started_at
      validate_on_or_after(@record.trial_concluded_at, :retrial_started_at, :check_not_earlier_than_trial_concluded)
      validate_retrial_start_and_end(:retrial_started_at, :retrial_concluded_at, inverse: false)
    end

    # cannot be before the first day of retrial
    # cannot be before the first rep order was granted
    # cannot be more than 5 years in the past
    def validate_retrial_concluded_at
      validate_retrial_start_and_end(:retrial_started_at, :retrial_concluded_at, inverse: true)
    end

    def validate_main_hearing_date
      validate_too_far_in_past(:main_hearing_date)
    end

    # local helpers
    # ---------------------------
    def method_missing(method, *args)
      if method.to_s.match?(/^requires_(re){0,1}trial_dates\?/)
        begin
          @record.case_type.__send__(method)
        rescue NoMethodError
          false
        end
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      method.to_s.match?(/^requires_(re){0,1}trial_dates\?/) || super
    end

    def validate_trial_length(field)
      return unless requires_trial_dates?
      validate_presence(field, :blank)
      validate_numericality(field, :invalid, 0, nil) unless @record.__send__(field).nil?
    end

    def validate_retrial_length(field)
      return unless requires_retrial_dates?
      # TODO: this condition is a temproary workaround for live data that existed prior to addition of retrial details
      validate_presence(field, 'blank') if @record.editable?
      validate_numericality(field, 'invalid', 0, nil) unless @record.__send__(field).nil?
    end

    def validate_trial_actual_length_consistency
      return unless actual_length_consistent?(requires_trial_dates?,
                                              @record.actual_trial_length,
                                              @record.first_day_of_trial,
                                              @record.trial_concluded_at)
      add_error(:actual_trial_length, :too_long)
    end

    def validate_retrial_actual_length_consistency
      return unless actual_length_consistent?(requires_retrial_dates?,
                                              @record.retrial_actual_length,
                                              @record.retrial_started_at,
                                              @record.retrial_concluded_at)
      add_error(:retrial_actual_length, :too_long)
    end

    def validate_travel_expense_additional_information
      return if @record.from_api?
      return unless @record.expenses.any?
      validate_presence(:travel_expense_additional_information, :higher_rate_travel_claimed) if has_higher_rate_mileage?
      validate_presence(:travel_expense_additional_information, :calculated_travel_increased) if increased_travel?
    end

    def actual_length_consistent?(requires_dates, actual_length, start_date, end_date)
      requires_dates &&
        actual_length.present? &&
        start_date.present? &&
        end_date.present? &&
        trial_length_valid?(end_date, start_date, actual_length)
    end

    def trial_length_valid?(concluded, started, actual_length)
      # As we are using Date objects without time information, we loose precision, so adding 1 day will workaround this.
      ((concluded - started).days + 1.day) < actual_length.days
    end

    def cracked_case?
      @record&.case_type&.name&.match?(/[Cc]racked/)
    end

    def has_fees_or_expenses_attributes?
      (@record.fixed_fees.present? || @record.misc_fees.present?) ||
        (@record.basic_fees.present? || @record.expenses.present?)
    end

    def fixed_fee_case?
      @record&.fixed_fee_case?
    end

    def snake_case_type
      @record.case_type.name.downcase.tr(' ', '_')
    end

    def earliest_rep_order
      @record.earliest_representation_order_date
    end

    def validate_trial_start_and_end(start_attribute, end_attribute, inverse: false)
      start_attribute, end_attribute = end_attribute, start_attribute if inverse
      validate_presence(start_attribute, :blank)
      method(:"validate_on_or_#{inverse ? 'after' : 'before'}")
        .call(@record.__send__(end_attribute), start_attribute, :check_other_date)

      validate_too_far_in_past(start_attribute)
    end

    def validate_retrial_start_and_end(start_attribute, end_attribute, inverse: false)
      return unless @record&.requires_retrial_dates?
      start_attribute, end_attribute = end_attribute, start_attribute if inverse
      # TODO: this condition is a temproary workaround for live data that existed prior to addition of retrial details
      validate_presence(start_attribute, :blank) if @record.editable?
      method(:"validate_on_or_#{inverse ? 'after' : 'before'}")
        .call(@record.__send__(end_attribute), start_attribute, :check_other_date)

      validate_on_or_after(earliest_rep_order, start_attribute, :check_not_earlier_than_rep_order)
      validate_too_far_in_past(start_attribute)
    end

    def validate_too_far_in_past(start_attribute)
      validate_on_or_after(Settings.earliest_permitted_date, start_attribute, :check_not_too_far_in_past)
    end

    def has_higher_rate_mileage?
      destinations = %w[magistrates_court prison]
      @record.expenses.find { |x| x.mileage_rate_id.eql?(2) && destinations.exclude?(x&.establishment&.category) }
    end

    def increased_travel?
      @record.expenses.find { |x| x.calculated_distance && x.distance && (x.distance > x.calculated_distance) }
    end

    def validate_earliest_representation_order_date
      return unless @record.case_type&.name == 'Elected cases not proceeded'
      return unless @record.earliest_representation_order_date
      return if allow_elected_case_not_proceeded?

      @record.errors.add(:earliest_representation_order_date,
                         'invalid for elected case not proceeded and main hearing date')
    end

    def allow_elected_case_not_proceeded?
      # This applies to both agfs fee scheme 13 and lgfs fee scheme 10 but the dates are the same
      pre_clair_rep_order = @record.earliest_representation_order_date.before?(
        Settings.agfs_scheme_13_clair_release_date
      )
      return pre_clair_rep_order unless @record.main_hearing_date

      pre_clair_rep_order && @record.main_hearing_date.before?(Settings.clair_contingency_date)
    end
  end
end
