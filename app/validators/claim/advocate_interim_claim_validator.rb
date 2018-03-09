class Claim::AdvocateInterimClaimValidator < Claim::BaseClaimValidator
  def self.fields_for_steps
    {
      case_details: %i[
        court
        case_number
        case_transferred_from_another_court
        transfer_court
        transfer_case_number
        supplier_number
      ],
      defendants: [],
      offence_details: %i[offence],
      fees: %i[
        advocate_category
        total
        defendant_uplifts
      ]
    }
  end

  private

  #
  # def validate_creator
  #   super if defined?(super)
  #   validate_has_role(@record.creator.try(:provider),
  #                     :agfs,
  #                     :creator,
  #                     'must be from a provider with permission to submit AGFS claims')
  # end
  #
  # def validate_advocate_category
  #   validate_presence(:advocate_category, 'blank')
  #   return if @record.advocate_category.blank?
  #   validate_inclusion(:advocate_category, Settings.advocate_categories, I18n.t('validators.advocate.category'))
  # end
  #
  # def validate_offence
  #   validate_presence(:offence, 'blank') unless fixed_fee_case?
  # end
  #

  def validate_supplier_number
    validate_pattern(:supplier_number, ExternalUser::SUPPLIER_NUMBER_REGEX, 'invalid')
  end
  #
  # def validate_defendant_uplifts
  #   return if @record.from_api?
  #   no_of_defendants = @record.defendants.reject(&:marked_for_destruction?).size
  #   add_error(:base, 'defendant_uplifts_mismatch') if defendant_uplifts_greater_than?(no_of_defendants)
  # end
  #
  # # we add one because uplift quantities reflect the number of "additional" defendants
  # def defendant_uplifts_greater_than?(no_of_defendants)
  #   @record
  #     .fees
  #     .where.not(id: @record.misc_fees.select(&:marked_for_destruction?).map(&:id))
  #     .defendant_uplift_sums
  #     .values
  #     .map(&:to_i).any? { |sum| sum + 1 > no_of_defendants }
  # end
end
