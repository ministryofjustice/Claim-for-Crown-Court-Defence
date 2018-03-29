class Fee::BasicFeePresenter < Fee::BaseFeePresenter
  def prompt_text
    return unless FEE_CODES_WITH_PROMPT_TEXT.include?(code)

    t_scope = %i[external_users claims basic_fees basic_fee_calculated_fields]

    case code
    when 'BAF'
      key = claim.fee_scheme == 'fee_reform' ? 'basic_fee_reform_prompt_text' : 'basic_fee_prompt_text'
      I18n.t(key, scope: t_scope)
    when 'SAF'
      return if claim.fee_scheme == 'fee_reform'
      I18n.t('saf_prompt_text', scope: t_scope)
    end
  end

  def display_amount?
    # TODO: this is not really ideal, but right now I
    # can't see any other way to achieve this specific
    # requirement :/
    return true unless claim.fee_scheme == 'fee_reform'
    return false if FEE_CODES_WITHOUT_AMOUNT.include?(code)
    true
  end

  private

  FEE_CODES_WITH_PROMPT_TEXT = %w[BAF SAF].freeze
  FEE_CODES_WITHOUT_AMOUNT = %w[PPE].freeze

  def code
    fee.fee_type.code
  end

  def claim
    fee.claim
  end
end
