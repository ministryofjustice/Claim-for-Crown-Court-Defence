class Claim::AdvocateClaimPresenter < Claim::BaseClaimPresenter
  present_with_currency :basic_fees_total, :fixed_fees_total

  # NOTE: this shows we should probably refactor the template naming
  # to bring some consistency between claim steps and their associated
  # templates
  SUMMARY_SECTIONS = {
    case_details: :case_details,
    defendants: :defendants,
    offence_details: :offence_details,
    basic_fees: :basic_fees,
    fixed_fees: :fixed_fees,
    misc_fees: :miscellaneous_fees,
    expenses: :travel_expenses,
    supporting_evidence: :supporting_evidence,
    additional_information: :supporting_evidence
  }.freeze

  def pretty_type
    'AGFS Final'
  end

  def type_identifier
    'agfs_final'
  end

  def can_have_disbursements?
    false
  end

  def raw_fixed_fees_total
    claim.calculate_fees_total(:fixed_fees)
  end

  def raw_basic_fees_total
    claim.calculate_fees_total(:basic_fees)
  end

  def raw_fixed_fees_combined_total
    raw_fixed_fees_total + raw_basic_fees_total + raw_misc_fees_total
  end

  def summary_sections
    SUMMARY_SECTIONS
  end

  # NOTE: this is an interim solution for what probably should be
  # some sort of DSL to describe what fields are required for a given section
  # for that section to be considered completed
  def mandatory_case_details?
    claim.case_type && claim.court && claim.case_number && claim.external_user
  end

  def requires_interim_claim_info?
    claim.agfs_reform?
  end
end
