class Fee::BaseFeePresenter < BasePresenter
  presents :fee

  def dates_attended_delimited_string
    fee.dates_attended.order(date: :asc).map(&:to_s).join(', ')
  end

  def date
    format_date(fee.date)
  end

  def rate
    if fee.calculated?
      h.number_to_currency fee.rate
    else
      not_applicable
    end
  end

  def rate_as_float
    if fee.calculated?
      h.number_with_precision(fee.rate, precision: 2)
    else
      not_applicable
    end
  end

  def amount
    h.number_to_currency(fee.amount)
  end

  def section_header(t_scope)
    uncalculated_fee_type_code? ? t(t_scope, '_section_header') : fee.fee_type.description
  end

  def section_hint(t_scope)
    uncalculated_fee_type_code? ? t(t_scope, '_section_hint') : ''
  end

  def quantity
    # if the error is that the user has typed a decimal when it should be an integer,
    # we want to preserve the decimal value and display on the error page
    #
    if fee.quantity_is_decimal? || fee.errors[:quantity].include?('integer')
      h.number_with_precision(fee.quantity, precision: 2)
    else
      h.number_with_precision(fee.quantity, precision: 0)
    end
  end

  def display_amount?
    true
  end

  private

  def t(scope, suffix = nil)
    I18n.t("#{scope}.#{fee.fee_type.code.downcase}#{suffix}")
  end

  def uncalculated_fee_type_code?
    %w[PPE NPW].include?(fee.fee_type.code.upcase)
  end

  def hint_tag(text)
    h.content_tag :div, text, class: 'form-hint'
  end

  def not_applicable
    hint_tag I18n.t('general.not_applicable')
  end
end
