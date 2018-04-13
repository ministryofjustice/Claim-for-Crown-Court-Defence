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

# Class to return the vat rate in base points (i.e. 1750 = a vat rate of 17.5%).
# All rates are cached in a class variable on first use to prevent re-reading the vat_rates table
# every time.
#
class VatRate < ApplicationRecord
  class MissingVatRateError < RuntimeError; end

  validates :effective_date, uniqueness: true

  class << self
    def for_date(date)
      rate_for_date(date)
    end

    # Calculate VAT amount for amount_excluding_vat on a given date
    def vat_amount(amount_excluding_vat, date, calculate: true)
      rate = calculate ? VatRate.for_date(date) : 0
      (amount_excluding_vat * rate / 10_000.0).round(2)
    end

    # returns "22.25%", "17/5%', 8%", etc
    def pretty_rate(date)
      rate = rate_for_date(date) / 100.0

      # transform to integer if whole number to supress printing of .0
      rate = rate.to_i if (rate - rate.to_i).zero?
      format('%{rate}%%', rate: rate.to_s)
    end

    private

    def rates
      VatRate.all.order(effective_date: :desc)
    end

    def rate_for_date(date)
      result = nil
      rates.each do |rec|
        unless date < rec.effective_date
          result = rec
          break
        end
      end
      err_msg = "There is no VAT rate for date #{date.strftime(Settings.date_format)}"
      raise VatRate::MissingVatRateError, err_msg if result.nil?
      result.rate_base_points
    end
  end
end
