class Fee::FixedFeePresenter < Fee::BaseFeePresenter
  def fee_category_name
    'Fixed Fees'
  end

  def quantity
    agfs? ? super : not_applicable
  end

  def rate
    agfs? ? super : not_applicable
  end

  private

  def agfs?
    fee&.claim&.agfs? ? true : false
  end
end
