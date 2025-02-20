class Fee::BasicFeePresenter < Fee::BaseFeePresenter
  def should_be_displayed?
    return true unless claim.agfs_reform?
    return true unless FEE_CODES_RESTRICTED_DISPLAY.include?(code)
    OFFENCE_CATEGORIES_WITHOUT_RESTRICTED_DISPLAY.include?(offence_category_number)
  end

  def display_extra_fees?
    return false if claim.discontinuance?
    should_be_displayed?
  end

  def display_amount?
    # TODO: this is not really ideal, but right now I
    # can't see any other way to achieve this specific
    # requirement :/
    return true unless claim.agfs_reform?
    return false if FEE_CODES_WITHOUT_AMOUNT.include?(code)
    true
  end

  def display_help_text?
    return false unless claim.agfs_reform?
    OFFENCE_CATEGORIES_WITHOUT_RESTRICTED_DISPLAY.include?(offence_category_number)
  end

  def activate_js_block?
    !display_help_text?
  end

  def fee_calc_class
    { BAPPE: 'js-fee-calculator-ppe', BANPW: 'js-fee-calculator-pw' }[unique_code.to_sym]
  end

  FEE_CODES_WITH_PROMPT_TEXT = %w[BAF SAF PPE].freeze
  FEE_CODES_WITHOUT_AMOUNT = %w[PPE].freeze
  FEE_CODES_RESTRICTED_DISPLAY = %w[PPE].freeze
  OFFENCE_CATEGORIES_WITHOUT_RESTRICTED_DISPLAY = [6, 9].freeze
  private_constant :FEE_CODES_WITH_PROMPT_TEXT, :FEE_CODES_WITHOUT_AMOUNT, :FEE_CODES_RESTRICTED_DISPLAY,
                   :OFFENCE_CATEGORIES_WITHOUT_RESTRICTED_DISPLAY

  private

  def code
    fee.fee_type.code
  end

  def unique_code
    fee.fee_type.unique_code
  end

  def claim
    fee.claim
  end

  def offence_category_number
    claim&.offence&.offence_category&.number
  end
end
