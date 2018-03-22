class Fee::BasicFeePresenter < Fee::BaseFeePresenter
  def display_amount?
    # TODO: this is not really ideal, but right now I
    # can't see any other way to achieve this specific
    # requirement :/
    return true unless claim.fee_scheme == 'fee_reform'
    return false if FEE_CODES_WITHOUT_AMOUNT.include?(fee.fee_type.code)
    true
  end

  private

  FEE_CODES_WITHOUT_AMOUNT = %w[PPE].freeze

  def claim
    fee.claim
  end
end
