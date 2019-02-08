class Claim::AdvocateInterimClaimValidator < Claim::BaseClaimValidator
  include Claim::AdvocateClaimCommonValidations

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

  def validate_earliest_representation_order
    date = @record.earliest_representation_order&.representation_order_date
    return unless date.present?
    add_error(:base, 'unclaimable') unless date >= Date.parse(Settings.agfs_fee_reform_release_date.to_s)
  end

  def validate_offence
    validate_presence(:offence, 'new_blank')
  end
end
