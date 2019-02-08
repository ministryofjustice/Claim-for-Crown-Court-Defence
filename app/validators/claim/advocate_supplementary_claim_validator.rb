class Claim::AdvocateSupplementaryClaimValidator < Claim::BaseClaimValidator
  def self.fields_for_steps
    {
      case_details: %i[
        court
        case_number
        case_transferred_from_another_court
        transfer_court
        transfer_case_number
        case_concluded_at
        supplier_number
      ],
      defendants: [],
      miscellaneous_fees: %i[advocate_category defendant_uplifts_misc_fees],
      travel_expenses: %i[travel_expense_additional_information],
      supporting_evidence: []
    }
  end

  FEE_VALIDATION_FIELDS = %i[total].freeze

  private

  # TODO: advocate claim validation mixin?
  def supplier_number_regex
    ExternalUser::SUPPLIER_NUMBER_REGEX
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin?
  def validate_creator
    super if defined?(super)
    validate_has_role(@record.creator.try(:provider),
                      :agfs,
                      :creator,
                      'must be from a provider with permission to submit AGFS claims')
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin?
  def validate_advocate_category
    validate_presence(:advocate_category, 'blank')
    return if @record.advocate_category.blank?
    validate_inclusion(:advocate_category, @record.eligible_advocate_categories, I18n.t('validators.advocate.category'))
  end

  # NOTE: opposite of advocate claim
  def validate_offence
    validate_absence(:offence, 'present')
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin?
  def validate_case_concluded_at
    validate_absence(:case_concluded_at, 'present')
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin?
  def validate_supplier_number
    validate_pattern(:supplier_number, supplier_number_regex, 'invalid')
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin? does not apply to advocate interim and misc claim but harmless to add?
  def validate_defendant_uplifts_basic_fees
    return if @record.from_api? || @record.fixed_fee_case?
    return unless defendant_uplifts_greater_than?(defendant_uplifts_basic_fees_counts, number_of_defendants)
    add_error(:base, 'defendant_uplifts_basic_fees_mismatch')
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin? does not apply to advocate interim and misc claim but harmless to add?
  def validate_defendant_uplifts_fixed_fees
    return if @record.from_api? || !@record.fixed_fee_case?
    return unless defendant_uplifts_greater_than?(defendant_uplifts_fixed_fees_counts, number_of_defendants)
    position = @record.fixed_fees.find_index(&:defendant_uplift?) + 1
    add_error("fixed_fee_#{position}_quantity", 'defendant_uplifts_fixed_fees_mismatch')
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin? does not apply to advocate interim claim but harmless to add?
  def validate_defendant_uplifts_misc_fees
    return if @record.from_api?
    return unless defendant_uplifts_greater_than?(defendant_uplifts_misc_fees_counts, number_of_defendants)
    add_error(:base, 'defendant_uplifts_misc_fees_mismatch')
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin? does not apply to advocate interim claim but harmless to add?
  def number_of_defendants
    @record.defendants.reject(&:marked_for_destruction?).size
  end

  # we add one because uplift quantities reflect the number of "additional" defendants
  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin? does not apply to advocate interim claim but harmless to add?
  def defendant_uplifts_greater_than?(defendant_uplifts_counts, no_of_defendants)
    defendant_uplifts_counts.map(&:to_i).any? { |sum| sum + 1 > no_of_defendants }
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin? does not apply to advocate interim claim but harmless to add?
  def defendant_uplifts_basic_fees
    defendant_uplifts_fees(@record.basic_fees)
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin? does not apply to advocate interim and misc claims but harmless to add?
  def defendant_uplifts_fixed_fees
    defendant_uplifts_fees(@record.fixed_fees)
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin? does not apply to advocate interim claim but harmless to add?
  def defendant_uplifts_misc_fees
    defendant_uplifts_fees(@record.misc_fees)
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin? does not apply to advocate interim claim but harmless to add?
  def defendant_uplifts_fees(fees)
    fees.select do |fee|
      !fee.marked_for_destruction? &&
        fee&.defendant_uplift?
    end
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin? does not apply to advocate interim and misc claim but harmless to add?
  def defendant_uplifts_basic_fees_counts
    defendant_uplifts_counts_for(defendant_uplifts_basic_fees)
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin? does not apply to advocate interim and misc claim but harmless to add?
  def defendant_uplifts_fixed_fees_counts
    defendant_uplifts_counts_for(defendant_uplifts_fixed_fees)
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin? does not apply to advocate interim claim but harmless to add?
  def defendant_uplifts_misc_fees_counts
    defendant_uplifts_counts_for(defendant_uplifts_misc_fees)
  end

  # TODO: SUPPLEMENTARY_CLAIM_TODO advocate claim validation mixin? does not apply to advocate interim claim but harmless to add?
  def defendant_uplifts_counts_for(defendant_uplifts)
    defendant_uplifts.each_with_object({}) do |fee, res|
      res[fee.fee_type.unique_code] ||= []
      res[fee.fee_type.unique_code] << fee.quantity
    end.values.map(&:sum)
  end
end
