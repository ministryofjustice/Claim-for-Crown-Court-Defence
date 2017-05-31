class Fee::TransferFeePresenter < Fee::BaseFeePresenter
  def rate
    not_applicable
  end
end
