class VatRatesController < ApplicationController

  skip_load_and_authorize_resource only: [:index]


  # expects an net_amount(as a string whit two decimal places and a date)
  # returns a JSON struct as follws:

  respond_to :json

  def index
    net_amount = params['net_amount'].to_f.round(2)
    apply_vat = params['apply_vat']
    date = Date.parse(params['date'])
    vat_amount = VatRate.vat_amount(net_amount, date)
    total_inc_vat = (net_amount || 0) + (vat_amount || 0)
    if apply_vat == 'true'
      respond_with(
        {
          'net_amount'    => ActionController::Base.helpers.number_to_currency(net_amount),
          'date'          => date.strftime(Settings.date_format),
          'rate'          => VatRate.pretty_rate(date),
          'vat_amount'    => ActionController::Base.helpers.number_to_currency(VatRate.vat_amount(net_amount, date)),
          'total_inc_vat' => ActionController::Base.helpers.number_to_currency(total_inc_vat)
        }
      )
    else
      respond_with(
        {
          'net_amount'    => ActionController::Base.helpers.number_to_currency(net_amount),
          'date'          => '',
          'rate'          => "0%",
          'vat_amount'    => ActionController::Base.helpers.number_to_currency(0),
          'total_inc_vat' => ActionController::Base.helpers.number_to_currency(net_amount)
        }
      )
    end
  end


end
