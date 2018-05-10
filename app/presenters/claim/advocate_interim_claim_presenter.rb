class Claim::AdvocateInterimClaimPresenter < Claim::BaseClaimPresenter
  # NOTE: this shows we should probably refactor the template naming
  # to bring some consistency between claim steps and their associated
  # templates
  SUMMARY_SECTIONS = {
    case_details: :case_details,
    defendants: :defendants,
    offence_details: :offence_details,
    warrant_fee: :interim_fees,
    expenses: :travel_expenses,
    supporting_evidence: :supporting_evidence,
    additional_information: :supporting_evidence
  }.freeze

  def pretty_type
    'AGFS Warrant'
  end

  def type_identifier
    'agfs_interim'
  end

  def can_have_disbursements?
    false
  end

  def raw_warrant_fees_total
    claim.warrant_fee&.amount || 0
  end
  present_with_currency :warrant_fees_total

  def summary_sections
    SUMMARY_SECTIONS
  end

  # NOTE: this is an interim solution for what probably should be
  # some sort of DSL to describe what fields are required for a given section
  # for that section to be considered completed
  def mandatory_case_details?
    claim.court && claim.case_number && claim.external_user
  end

  # NOTE: this is an interim solution for what probably should be
  # some sort of DSL to describe what fields are required for a given section
  # for that section to be considered completed
  def mandatory_supporting_evidence?
    claim.documents.any? || claim.evidence_checklist_ids.any?
  end
end
