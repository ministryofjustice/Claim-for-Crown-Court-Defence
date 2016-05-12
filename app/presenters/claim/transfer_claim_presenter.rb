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
    elected_case_part +
    transfer_stage_part +
    litigator_type_part +
    case_conclusion_part
  end

  def litigator_type_description
    claim.litigator_type.humanize
  end

  def elected_case_description
    (claim.elected_case ? 'yes' : 'no').humanize
  end

  def transfer_stage_description
    transfer_stage_part
  end

  def transfer_date
    claim.transfer_date.strftime(Settings.date_format) rescue ''
  end

  def case_conclusion_description
    case_conclusions[claim.case_conclusion_id.to_s] rescue ''
  end

  private

  def elected_case_part
    claim.elected_case ? 'elected case - ' : ''
  end

  def transfer_stage_part
    transfer_stages[transfer_stage_id.to_s] || ''
  end

  def litigator_type_part
    case claim.litigator_type
      when 'original'
        ' (org)'
      when 'new'
       ' (new)'
      else
        ''
    end
  end

  def case_conclusion_part
    ' - ' + case_conclusions[claim.case_conclusion_id.to_s].downcase rescue ''
  end

end
