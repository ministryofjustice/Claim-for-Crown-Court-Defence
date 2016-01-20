class FeePresenter < BasePresenter

  presents :fee

  def dates_attended_delimited_string
    fee.dates_attended.order(date: :asc).map(&:to_s).join(', ')
  end

 def rate
    '%.2f' % fee.rate if fee.rate
 end

 def amount
    h.number_to_currency(fee.amount)
 end

 def header_and_hint(scope)
    if ['PPE','NPW'].include?(fee.fee_type.code.upcase)
      header = I18n.t("#{scope}.#{fee.fee_type.code.downcase}_section_header")
      hint = I18n.t("#{scope}.#{fee.fee_type.code.downcase}_section_hint")
      html = "<legend class='bold-medium'>#{header}</legend><div class='form-hint'>#{hint}</div>"
    else
      html = fee.fee_type.description
    end
    html.html_safe
 end

end