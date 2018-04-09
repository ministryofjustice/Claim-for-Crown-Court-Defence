class Claim::AdvocateClaimValidator < Claim::BaseClaimValidator
  def self.fields_for_steps
    {
      case_details: %i[
        case_type
        court
        case_number
        case_transferred_from_another_court
        transfer_court
        transfer_case_number
        estimated_trial_length
        actual_trial_length
        retrial_estimated_length
        retrial_actual_length
        trial_cracked_at_third
        trial_fixed_notice_at
        trial_fixed_at
        trial_cracked_at
        trial_dates
        retrial_started_at
        retrial_concluded_at
        case_concluded_at
        supplier_number
      ],
      defendants: [],
      offence_details: %i[offence],
      basic_and_fixed_fees: FEE_VALIDATION_FIELDS + %i[advocate_category defendant_uplifts],
      miscellaneous_fees: FEE_VALIDATION_FIELDS,
      travel_expenses: FEE_VALIDATION_FIELDS,
      supporting_evidence: [],
      additional_information: []
    }
  end

  FEE_VALIDATION_FIELDS = %i[total].freeze

  private

  def supplier_number_regex
    ExternalUser::SUPPLIER_NUMBER_REGEX
  end

  def validate_creator
    super if defined?(super)
    validate_has_role(@record.creator.try(:provider),
                      :agfs,
                      :creator,
                      'must be from a provider with permission to submit AGFS claims')
  end

  def validate_advocate_category
    validate_presence(:advocate_category, 'blank')
    return if @record.advocate_category.blank?
    validate_inclusion(:advocate_category, @record.eligible_advocate_categories, I18n.t('validators.advocate.category'))
  end

  def validate_offence
    return if fixed_fee_case?
    error_message = @record.fee_scheme == 'fee_reform' ? 'new_blank' : 'blank'
    validate_presence(:offence, error_message)
  end

  def validate_case_concluded_at
    validate_absence(:case_concluded_at, 'present')
  end

  def validate_supplier_number
    validate_pattern(:supplier_number, supplier_number_regex, 'invalid')
  end

  def validate_defendant_uplifts
    return if @record.from_api?
    no_of_defendants = @record.defendants.reject(&:marked_for_destruction?).size
    add_error(:base, 'defendant_uplifts_mismatch') if defendant_uplifts_greater_than?(no_of_defendants)
  end

  # we add one because uplift quantities reflect the number of "additional" defendants
  def defendant_uplifts_greater_than?(no_of_defendants)
    defendant_uplifts_counts.map(&:to_i).any? { |sum| sum + 1 > no_of_defendants }
  end

  def defendant_uplifts
    (@record.basic_fees + @record.fixed_fees + @record.misc_fees).select do |fee|
      !fee.marked_for_destruction? &&
        fee&.defendant_uplift?
    end
  end

  def defendant_uplifts_counts
    defendant_uplifts.each_with_object({}) do |fee, res|
      res[fee.fee_type.unique_code] ||= []
      res[fee.fee_type.unique_code] << fee.quantity
    end.values.map(&:sum)
  end
end
