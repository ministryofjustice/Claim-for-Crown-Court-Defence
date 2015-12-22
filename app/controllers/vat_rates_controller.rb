class VatRatesController < ApplicationController

  skip_load_and_authorize_resource only: [:index]


  # expects an net_amount(as a string whit two decimal places and a date)
  # returns a JSON struct as follws:

  respond_to :json

  def index
      respond_with(
        {
          'net_amount'    => number_to_currency(net_amount),
          'date'          => formatted_date,
          'rate'          => rate,
          'vat_amount'    => number_to_currency(vat_amount),
          'total_inc_vat' => total
        }
      )
  end

  private

  def apply_vat
    params['apply_vat'] == 'true' ? true : false
  end

  def date
    Date.parse(params['date'])
  end

  def formatted_date
    apply_vat ? date.strftime(Settings.date_format) : ''
  end

  def net_amount
    params['net_amount'].to_f.round(2)
  end

  def rate
    apply_vat ? VatRate.pretty_rate(date) : '0%'
  end

  def vat_amount
    apply_vat ? VatRate.vat_amount(net_amount, date) : 0
  end

  def total_inc_vat
    (net_amount || 0) + (vat_amount || 0)
  end

  def total
    apply_vat ? number_to_currency(total_inc_vat) : number_to_currency(net_amount)
  end

  def number_to_currency(number)
    ActionController::Base.helpers.number_to_currency(number)
  end

end
