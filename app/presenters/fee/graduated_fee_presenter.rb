class Fee::GraduatedFeePresenter < Fee::BaseFeePresenter
  def rate
    not_applicable
  end
end
