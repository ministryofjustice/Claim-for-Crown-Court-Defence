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
      basic_fees: FEE_VALIDATION_FIELDS + %i[
        advocate_category defendant_uplifts_basic_fees
      ],
      fixed_fees: FEE_VALIDATION_FIELDS + %i[
        advocate_category defendant_uplifts_fixed_fees
      ],
      miscellaneous_fees: %i[defendant_uplifts_misc_fees],
      travel_expenses: [],
      supporting_evidence: []
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
    error_message = @record.agfs_reform? ? 'new_blank' : 'blank'
    validate_presence(:offence, error_message)
  end

  def validate_case_concluded_at
    validate_absence(:case_concluded_at, 'present')
  end

  def validate_supplier_number
    validate_pattern(:supplier_number, supplier_number_regex, 'invalid')
  end

  def validate_defendant_uplifts_basic_fees
    return if @record.from_api? || @record.fixed_fee_case?
    return unless defendant_uplifts_greater_than?(defendant_uplifts_basic_fees_counts, number_of_defendants)
    add_error(:base, 'defendant_uplifts_basic_fees_mismatch')
  end

  def validate_defendant_uplifts_fixed_fees
    return if @record.from_api? || !@record.fixed_fee_case?
    return unless defendant_uplifts_greater_than?(defendant_uplifts_fixed_fees_counts, number_of_defendants)
    add_error(:base, 'defendant_uplifts_fixed_fees_mismatch')
  end

  def validate_defendant_uplifts_misc_fees
    return if @record.from_api?
    return unless defendant_uplifts_greater_than?(defendant_uplifts_misc_fees_counts, number_of_defendants)
    add_error(:base, 'defendant_uplifts_misc_fees_mismatch')
  end

  def number_of_defendants
    @record.defendants.reject(&:marked_for_destruction?).size
  end

  # we add one because uplift quantities reflect the number of "additional" defendants
  def defendant_uplifts_greater_than?(defendant_uplifts_counts, no_of_defendants)
    defendant_uplifts_counts.map(&:to_i).any? { |sum| sum + 1 > no_of_defendants }
  end

  def defendant_uplifts_basic_fees
    defendant_uplifts_fees(@record.basic_fees)
  end

  def defendant_uplifts_fixed_fees
    defendant_uplifts_fees(@record.fixed_fees)
  end

  def defendant_uplifts_misc_fees
    defendant_uplifts_fees(@record.misc_fees)
  end

  def defendant_uplifts_fees(fees)
    fees.select do |fee|
      !fee.marked_for_destruction? &&
        fee&.defendant_uplift?
    end
  end

  def defendant_uplifts_basic_fees_counts
    defendant_uplifts_counts_for(defendant_uplifts_basic_fees)
  end

  def defendant_uplifts_fixed_fees_counts
    defendant_uplifts_counts_for(defendant_uplifts_fixed_fees)
  end

  def defendant_uplifts_misc_fees_counts
    defendant_uplifts_counts_for(defendant_uplifts_misc_fees)
  end

  def defendant_uplifts_counts_for(defendant_uplifts)
    defendant_uplifts.each_with_object({}) do |fee, res|
      res[fee.fee_type.unique_code] ||= []
      res[fee.fee_type.unique_code] << fee.quantity
    end.values.map(&:sum)
  end
end
