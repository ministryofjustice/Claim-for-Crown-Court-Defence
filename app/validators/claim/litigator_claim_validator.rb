class Claim::LitigatorClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    {
      case_details: %i[
        case_type
        court
        case_number
        case_transferred_from_another_court
        transfer_court
        transfer_case_number
        case_concluded_at
      ],
      defendants: [],
      offence_details: %i[offence],
      graduated_fees: %i[actual_trial_length total],
      miscellaneous_fees: %i[defendant_uplifts],
      supporting_evidence: []
    }
  end

  def validate_defendant_uplifts
    return if @record.from_api?
    return if defendant_uplifts.all?(&:blank?)
    no_of_defendants = @record.defendants.reject(&:marked_for_destruction?).size
    add_error(:base, 'lgfs_defendant_uplifts_mismatch') if defendant_uplifts_greater_than?(no_of_defendants)
  end

  # we add one because Defendant uplift fees are for "additional" defendants
  def defendant_uplifts_greater_than?(no_of_defendants)
    defendant_uplifts.size + 1 > no_of_defendants
  end

  def defendant_uplifts
    @record.misc_fees.select do |fee|
      !fee.marked_for_destruction? &&
        fee&.defendant_uplift?
    end
  end
end
