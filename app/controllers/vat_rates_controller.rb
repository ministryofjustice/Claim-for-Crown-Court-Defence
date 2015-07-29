class VatRatesController < ApplicationController

  skip_load_and_authorize_resource only: [:index]


  # expects an net_amount(as a string whit two decimal places and a date)
  # returns a JSON struct as follws:

  respond_to :json

  def index
    net_amount = params['net_amount'].to_f.round(2)
    date = Date.parse(params['date'])
    respond_with(
      {
        'net_amount' => net_amount.to_s,
        'date'       => date.strftime('%Y-%m-%d'),
        'rate'       => VatRate.pretty_rate(date),
        'vat_amount' => VatRate.vat_amount(net_amount, date).to_s
      }
    )
  end


end
