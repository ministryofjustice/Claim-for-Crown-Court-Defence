# == Schema Information
#
# Table name: vat_rates
#
#  id               :integer          not null, primary key
#  rate_base_points :integer
#  effective_date   :date
#  created_at       :datetime
#  updated_at       :datetime
#

class VatRatesController < ApplicationController
  skip_load_and_authorize_resource only: [:index]

  # expects an net_amount(as a string whit two decimal places and a date)
  # returns a JSON struct as follws:

  respond_to :json

  def index
    respond_with(
      'net_amount' => number_to_currency(net_amount),
      'date'          => formatted_date,
      'rate'          => rate,
      'vat_amount'    => number_to_currency(vat_amount),
      'total_inc_vat' => total
    )
  end

  private

  def scheme
    params['scheme']
  end

  def lgfs_vat_amount
    params['lgfs_vat_amount'].to_f.round(2)
  end

  def apply_vat
    params['apply_vat'] == 'true'
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
    if agfs?
      VatRate.vat_amount(net_amount, date, calculate: apply_vat)
    else
      lgfs_vat_amount
    end
  end

  def total_inc_vat
    (net_amount || 0) + (vat_amount || 0)
  end

  def total
    if agfs?
      apply_vat ? number_to_currency(total_inc_vat) : number_to_currency(net_amount)
    else
      number_to_currency(total_inc_vat)
    end
  end

  def number_to_currency(number)
    ActionController::Base.helpers.number_to_currency(number)
  end

  def agfs?
    scheme == 'agfs'
  end
end
