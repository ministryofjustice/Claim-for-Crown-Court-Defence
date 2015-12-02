class FeePresenter < BasePresenter

  presents :fee

  def dates_attended_delimited_string
    fee.dates_attended.order(date: :asc).map(&:to_s).join(', ')
  end


 def rate
    '%.2f' % fee.rate
 end

 def amount
    h.number_to_currency(fee.amount)
 end

end