class Fee::WarrantFeePresenter < Fee::BaseFeePresenter
  presents :fee

  def warrant_issued_date
    fee.warrant_issued_date.strftime(Settings.date_format) rescue ''
  end

  def warrant_executed_date
    fee.warrant_executed_date.strftime(Settings.date_format) rescue ''
  end

  def warrant_executed?
    fee.warrant_executed_date.present?
  end
end
