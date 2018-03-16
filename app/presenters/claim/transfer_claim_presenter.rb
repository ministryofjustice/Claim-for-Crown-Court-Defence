class Claim::TransferClaimPresenter < Claim::BaseClaimPresenter
  present_with_currency :transfer_fees_total

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
    claim.litigator_type.humanize
  end

  def elected_case_description
    (claim.elected_case ? 'yes' : 'no').humanize
  end

  def transfer_stage_description
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
end
