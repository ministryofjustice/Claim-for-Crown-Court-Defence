class Claim::TransferDetailPresenter < BasePresenter

  presents :transfer_detail

  def transfer_stages
    Claim::TransferBrain::TRANSFER_STAGES.stringify_keys
  end

  def case_conclusions
    Claim::TransferBrain::CASE_CONCLUSIONS.stringify_keys
  end

  def stringified_summary
    summary = elected_case_string +
              transfer_stage_string +
              litigator_type_string +
              case_conclusion_string
    summary.blank? ? 'Incomplete transfer details' : summary
  end

  def elected_case_string
    elected_case ? 'elected case - ' : ''
  end

  def transfer_stage_string
    transfer_stages[transfer_stage_id.to_s] || ''
  end

  def litigator_type_string
    case litigator_type
      when 'original'
        ' (org)'
      when 'new'
       ' (new)'
      else
        ''
    end
  end

  def case_conclusion_string
    ' - ' + case_conclusions[case_conclusion_id.to_s].downcase rescue ''
  end

end
