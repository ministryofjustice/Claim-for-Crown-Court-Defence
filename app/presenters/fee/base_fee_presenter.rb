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

  def amount
    h.number_to_currency(fee.amount)
  end

  def section_header(t_scope)
    header = if ['PPE', 'NPW'].include?(fee.fee_type.code.upcase)
               t(t_scope, '_section_header')
             else
               fee.fee_type.description
             end
    header.html_safe
  end

  def section_hint(t_scope)
    hint = if ['PPE', 'NPW'].include?(fee.fee_type.code.upcase)
               t(t_scope, '_section_hint')
             else
               fee.fee_type.description
             end
    hint.html_safe
  end

private

  def t(scope, suffix=nil)
    I18n.t("#{scope}.#{fee.fee_type.code.downcase}#{suffix}")
  end

  def hint_tag(text)
    h.content_tag :div, text, class: 'form-hint'
  end

  def not_applicable
    hint_tag I18n.t('general.not_applicable')
  end

end