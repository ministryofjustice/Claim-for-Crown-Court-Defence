class InterimClaimInfoPresenter < BasePresenter
  presents :interim_claim_info

  def warrant_issued_date
    format_date(interim_claim_info.warrant_issued_date)
  end

  def warrant_executed_date
    format_date(interim_claim_info.warrant_executed_date)
  end
end
