class Claim::AdvocateMiscClaimPresenter < Claim::BaseClaimPresenter
  # NOTE: this shows we should probably refactor the template naming
  # to bring some consistency between claim steps and their associated
  # templates
  SUMMARY_SECTIONS = {
    case_details: :case_details,
    defendants: :defendants,
    offence_details: :offence_details,
    misc_fees: :miscellaneous_fees,
    expenses: :travel_expenses,
    supporting_evidence: :supporting_evidence,
    additional_information: :supporting_evidence
  }.freeze

  def pretty_type
    'AGFS Miscellaneous'
  end

  def type_identifier
    'agfs_misc'
  end

  def can_have_disbursements?
    false
  end

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
