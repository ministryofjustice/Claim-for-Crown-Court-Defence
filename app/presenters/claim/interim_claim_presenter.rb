class Claim::InterimClaimPresenter < Claim::BaseClaimPresenter
  present_with_currency :interim_fees_total

  # NOTE: this shows we should probably refactor the template naming
  # to bring some consistency between claim steps and their associated
  # templates
  SUMMARY_SECTIONS = {
    case_details: :case_details,
    defendants: :defendants,
    offence_details: :offence_details,
    interim_fee: :interim_fees,
    disbursements: :interim_fees,
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

  def summary_sections
    SUMMARY_SECTIONS
  end

  # NOTE: this is an interim solution for what probably should be
  # some sort of DSL to describe what fields are required for a given section
  # for that section to be considered completed
  def mandatory_case_details?
    claim.court && claim.case_number && claim.supplier_number
  end

  def raw_interim_fees_vat
    VatRate.vat_amount(raw_interim_fees_total, claim.created_at, calculate: claim.apply_vat?)
  end

  def raw_interim_fees_gross
    raw_interim_fees_total + raw_interim_fees_vat
  end

  def interim_fees_vat
    h.number_to_currency(raw_interim_fees_vat)
  end

  def interim_fees_gross
    h.number_to_currency(raw_interim_fees_gross)
  end
end
