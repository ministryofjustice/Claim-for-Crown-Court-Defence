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
    elected_case_string +
    transfer_stage_string +
    litigator_type_string +
    case_conclusion_string
  end

  def transfer_date
    claim.transfer_date.strftime(Settings.date_format) rescue ''
  end

  private

  def elected_case_string
    claim.elected_case ? 'elected case - ' : ''
  end

  def transfer_stage_string
    transfer_stages[transfer_stage_id.to_s] || ''
  end

  def litigator_type_string
    case claim.litigator_type
      when 'original'
        ' (org)'
      when 'new'
       ' (new)'
      else
        ''
    end
  end

  def case_conclusion_string
    ' - ' + case_conclusions[claim.case_conclusion_id.to_s].downcase rescue ''
  end

end
