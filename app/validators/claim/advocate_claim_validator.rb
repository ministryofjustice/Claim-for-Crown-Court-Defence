class Claim::AdvocateClaimValidator < Claim::BaseClaimValidator
  def self.fields_for_steps
    [
      %i[
        case_type
        court
        case_number
        transfer_court
        transfer_case_number
        advocate_category
        offence
        estimated_trial_length
        actual_trial_length
        retrial_estimated_length
        retrial_actual_length
        trial_cracked_at_third
        trial_fixed_notice_at
        trial_fixed_at
        trial_cracked_at
        first_day_of_trial
        trial_concluded_at
        retrial_started_at
        retrial_concluded_at
        case_concluded_at
        supplier_number
      ],
      %i[
        total
        defendant_uplifts
      ]
    ]
  end

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
    validate_inclusion(:advocate_category, Settings.advocate_categories, I18n.t('validators.advocate.category'))
  end

  def validate_offence
    validate_presence(:offence, 'blank') unless fixed_fee_case?
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
    add_error(:base, 'Too many defendant uplifts claimed') if defendant_uplifts_greater_than?(no_of_defendants)
  end

  # we add one because uplift quantities reflect the number of "additional" defendants
  def defendant_uplifts_greater_than?(no_of_defendants)
    @record
      .misc_fees
      .defendant_uplift_sums
      .values
      .map(&:to_i).any? { |sum| sum + 1 > no_of_defendants }
  end
end
