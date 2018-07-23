class Fee::BasicFeePresenter < Fee::BaseFeePresenter
  def prompt_text
    return unless FEE_CODES_WITH_PROMPT_TEXT.include?(code)

    t_scope = %i[external_users claims basic_fees basic_fee_calculated_fields]

    key = prompt_text_key_for(code)

    return unless key
    I18n.t(key, scope: t_scope)
  end

  def should_be_displayed?
    return true unless claim.agfs_reform?
    return true unless FEE_CODES_RESTRICTED_DISPLAY.include?(code)
    OFFENCE_CATEGORIES_WITHOUT_RESTRICTED_DISPLAY.include?(offence_category_number)
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

  private

  FEE_CODES_WITH_PROMPT_TEXT = %w[BAF SAF PPE].freeze
  FEE_CODES_WITHOUT_AMOUNT = %w[PPE].freeze
  FEE_CODES_RESTRICTED_DISPLAY = %w[PPE].freeze
  OFFENCE_CATEGORIES_WITHOUT_RESTRICTED_DISPLAY = [6, 9].freeze

  def code
    fee.fee_type.code
  end

  def claim
    fee.claim
  end

  def offence_category_number
    claim&.offence&.offence_category&.number
  end

  def prompt_text_key_for(code)
    return default_prompt_text_for(code) unless claim.agfs_reform?
    fee_reform_prompt_text_for(code)
  end

  def default_prompt_text_for(code)
    {
      'BAF' => 'basic_fee_prompt_text',
      'SAF' => 'saf_prompt_text'
    }[code]
  end

  def fee_reform_prompt_text_for(code)
    {
      'BAF' => 'basic_fee_reform_prompt_text',
      'PPE' => 'ppe_fee_reform_prompt_text'
    }[code]
  end
end
