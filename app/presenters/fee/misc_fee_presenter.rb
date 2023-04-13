class Fee::MiscFeePresenter < Fee::BaseFeePresenter
  def quantity
    return not_applicable_html unless agfs?
    return not_applicable_html if fee_type.unique_code == 'MISTE'

    super
  end

  def rate
    agfs? ? super : not_applicable_html
  end

  def days_claimed
    super
  end

  private

  def agfs?
    fee&.claim&.agfs? ? true : false
  end
end
