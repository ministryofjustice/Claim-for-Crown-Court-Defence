class Fee::WarrantFeePresenter < Fee::BaseFeePresenter
  presents :fee

  def quantity
    not_applicable
  end

  def warrant_issued_date
    format_date(fee.warrant_issued_date)
  end

  def warrant_executed_date
    format_date(fee.warrant_executed_date)
  end

  def warrant_executed?
    fee.warrant_executed_date.present?
  end
end
