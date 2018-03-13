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
      fees: %i[
        advocate_category
        total
        defendant_uplifts
      ]
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
end
