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
      defendants: %i[earliest_representation_order],
      offence_details: %i[offence],
      interim_fees: %i[advocate_category]
    }
  end

  private

  def validate_supplier_number
    validate_pattern(:supplier_number, ExternalUser::SUPPLIER_NUMBER_REGEX, 'invalid')
  end

  def validate_earliest_representation_order
    date = @record.earliest_representation_order&.representation_order_date
    return unless date.present?
    add_error(:base, 'unclaimable') unless date >= Date.parse(Settings.agfs_fee_reform_release_date.to_s)
  end

  def validate_offence
    validate_presence(:offence, 'new_blank')
  end

  def validate_advocate_category
    validate_presence(:advocate_category, 'blank')
    return if @record.advocate_category.blank?
    validate_inclusion(:advocate_category, @record.eligible_advocate_categories, I18n.t('validators.advocate.category'))
  end
end
