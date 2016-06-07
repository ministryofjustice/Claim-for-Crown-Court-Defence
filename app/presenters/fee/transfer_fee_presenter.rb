class Fee::TransferFeePresenter < Fee::BaseFeePresenter
  def quantity
    not_applicable
  end

  def rate
    not_applicable
  end
end
