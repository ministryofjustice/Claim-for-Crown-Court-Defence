class Claim::TransferClaimPresenter < Claim::BaseClaimPresenter

  def pretty_type
    'Transfer'
  end

  def transfer_stages
    Claim::TransferBrain::TRANSFER_STAGES.stringify_keys
  end

  def case_conclusions
    Claim::TransferBrain::CASE_CONCLUSIONS.stringify_keys
  end

  def transfer_detail_summary
    Claim::TransferBrain.transfer_detail_summary(claim.transfer_detail) rescue ''
  end

  def litigator_type_description
    claim.litigator_type.humanize
  end

  def elected_case_description
    (claim.elected_case ? 'yes' : 'no').humanize
  end

  def transfer_stage_description
    Claim::TransferBrain.transfer_stage_by_id(claim.transfer_stage_id) || ''
  end

  def transfer_date
    claim.transfer_date.strftime(Settings.date_format) rescue ''
  end

  def case_conclusion_description
    case_conclusions[claim.case_conclusion_id.to_s] rescue ''
  end

end
