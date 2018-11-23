class Fee::MiscFeePresenter < Fee::BaseFeePresenter
  def quantity
    agfs? ? super : not_applicable
  end

  def rate
    agfs? ? super : not_applicable
  end

  def days_claimed
    super
  end

  private

  def agfs?
    fee&.claim&.agfs? ? true : false
  end
end
