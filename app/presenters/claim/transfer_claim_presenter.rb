class Claim::TransferClaimPresenter < Claim::BaseClaimPresenter
  present_with_currency :transfer_fees_total

  # NOTE: this shows we should probably refactor the template naming
  # to bring some consistency between claim steps and their associated
  # templates
  SUMMARY_SECTIONS = {
    transfer_detail: :transfer_fee_details,
    case_details: :case_details,
    defendants: :defendants,
    offence_details: :offence_details,
    transfer_fee: :transfer_fees,
    misc_fees: :miscellaneous_fees,
    disbursements: :disbursements,
    expenses: :travel_expenses,
    supporting_evidence: :supporting_evidence,
    additional_information: :supporting_evidence
  }.freeze

  def pretty_type
    'LGFS Transfer'
  end

  def transfer_stages
    Claim::TransferBrain::TRANSFER_STAGES.stringify_keys
  end

  def case_conclusions
    Claim::TransferBrain::CASE_CONCLUSIONS.stringify_keys
  end

  def transfer_detail_summary
    Claim::TransferBrain.transfer_detail_summary(claim.transfer_detail)
  rescue StandardError
    ''
  end

  def litigator_type_description
    claim.litigator_type&.humanize
  end

  def elected_case_description
    (claim.elected_case ? 'yes' : 'no').humanize
  end

  def transfer_stage_description
    return unless claim.transfer_stage_id
    Claim::TransferBrain.transfer_stage_by_id(claim.transfer_stage_id).description || ''
  end

  def transfer_date
    format_date(claim.transfer_date)
  end

  def case_conclusion_description
    case_conclusions[claim.case_conclusion_id.to_s]
  rescue StandardError
    ''
  end

  def type_identifier
    'lgfs_transfer'
  end

  def raw_transfer_fees_total
    claim.transfer_fee&.amount || 0
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
end
