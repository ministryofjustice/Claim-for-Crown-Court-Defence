class Claim::LitigatorClaimPresenter < Claim::BaseClaimPresenter
  # TODO: Any differences in baseclaimpresenters for litigators and advocates to be handled here
  present_with_currency :fixed_fees_total, :warrant_fees_total, :grad_fees_total

  # NOTE: this shows we should probably refactor the template naming
  # to bring some consistency between claim steps and their associated
  # templates
  SUMMARY_SECTIONS = {
    case_details: :case_details,
    defendants: :defendants,
    offence_details: :offence_details,
    fixed_fees: :fixed_fees,
    graduated_fees: :graduated_fees,
    misc_fees: :miscellaneous_fees,
    disbursements: :disbursements,
    expenses: :travel_expenses,
    supporting_evidence: :supporting_evidence,
    additional_information: :supporting_evidence
  }.freeze

  def pretty_type
    'LGFS Final'
  end

  def type_identifier
    'lgfs_final'
  end

  def fixed_fees
    [claim.fixed_fee].compact
  end

  def raw_fixed_fees_total
    claim.fixed_fee&.amount || 0
  end

  def raw_grad_fees_total
    claim.graduated_fee&.amount || 0
  end

  def raw_warrant_fees_total
    claim.warrant_fee&.amount || 0
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

  def requires_interim_claim_info?
    true
  end
end
