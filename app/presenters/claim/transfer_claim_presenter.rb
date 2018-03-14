class Claim::TransferClaimPresenter < Claim::BaseClaimPresenter
  present_with_currency :transfer_fees_total, :misc_fees_total, :total_inc

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

  def raw_misc_fees_total
    claim.calculate_fees_total(:misc) || 0
  end

  def raw_disbursements_total
    claim.disbursements_total || 0
  end

  def raw_disbursements_vat
    claim.disbursements_vat || 0
  end

  def raw_expenses_total
    claim.expenses_total
  end

  def raw_expenses_vat
    claim.expenses_vat
  end

  def raw_vat_amount
    claim.vat_amount
  end

  def raw_total_excl
    claim.total
  end

  def raw_total_inc
    claim.total + claim.vat_amount
  end
end
