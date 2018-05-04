class Claim::InterimClaimPresenter < Claim::BaseClaimPresenter
  present_with_currency :interim_fees_total, :warrant_fees_total

  # NOTE: this shows we should probably refactor the template naming
  # to bring some consistency between claim steps and their associated
  # templates
  SUMMARY_SECTIONS = {
    case_details: :case_details,
    defendants: :defendants,
    offence_details: :offence_details,
    interim_fee: :interim_fees,
    expenses: :travel_expenses,
    supporting_evidence: :supporting_evidence,
    additional_information: :supporting_evidence
  }.freeze

  def requires_trial_dates?
    false
  end

  def requires_retrial_dates?
    false
  end

  def can_have_expenses?
    false
  end

  def disbursement_only?
    claim.interim_fee&.is_disbursement?
  end

  def pretty_type
    'LGFS Interim'
  end

  def type_identifier
    'lgfs_interim'
  end

  def raw_interim_fees_total
    claim.interim_fee&.amount || 0
  end

  def raw_warrant_fees_total
    claim.warrant_fee&.amount || 0
  end

  def summary_sections
    SUMMARY_SECTIONS
  end
end
