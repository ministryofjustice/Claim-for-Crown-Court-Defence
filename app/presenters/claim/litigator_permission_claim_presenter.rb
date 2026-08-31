class Claim::LitigatorPermissionClaimPresenter < Claim::BaseClaimPresenter
  present_with_currency :permission_fees_total

  # Copied and slightly alterd from AdvocatePermissionClaimPresenter
  # More adjustment is probably required

  # NOTE: this shows we should probably refactor the template naming
  # to bring some consistency between claim steps and their associated
  # templates
  SUMMARY_SECTIONS = {
    case_details: :case_details,
    defendants: :defendants,
    offence_details: :offence_details,
    permission_fee: :permission_fees,
    misc_fees: :miscellaneous_fees,
    supporting_evidence: :supporting_evidence,
    additional_information: :supporting_evidence
  }.freeze

  def requires_trial_dates?
    false
  end

  def requires_retrial_dates?
    false
  end

  def pretty_type
    'LGFS Permission'
  end

  def type_identifier
    'lgfs_permission'
  end

  def summary_sections
    SUMMARY_SECTIONS
  end

  # NOTE: this is an interim solution for what probably should be
  # some sort of DSL to describe what fields are required for a given section
  # for that section to be considered completed
  def mandatory_case_details?
    claim.case_type && claim.court && claim.case_number && claim.supplier_number
  end

  def raw_permission_fees_total
    claim.permission_fee&.amount || 0
  end

  def raw_permission_fees_vat
    VatRate.vat_amount(raw_permission_fees_total, claim.created_at, calculate: claim.apply_vat?)
  end

  def raw_permission_fees_gross
    raw_permission_fees_total + raw_permission_fees_vat
  end

  def permission_fees_vat
    h.number_to_currency(raw_permission_fees_vat)
  end

  def permission_fees_gross
    h.number_to_currency(raw_permission_fees_gross)
  end
end
