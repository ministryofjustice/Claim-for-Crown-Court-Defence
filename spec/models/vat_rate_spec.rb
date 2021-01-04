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

require 'rails_helper'

RSpec.describe VatRate do
  before do
    VatRate.delete_all
    create(:vat_rate, effective_date: 1.year.ago, rate_base_points: 2225)
    create(:vat_rate, effective_date: 3.years.ago, rate_base_points: 800)
    create(:vat_rate, effective_date: 10.years.ago, rate_base_points: 1750)
  end

  describe '.for_date' do
    it 'should return 8% for dates between 1 and 3 years ago' do
      expect(VatRate.for_date(2.years.ago)).to eq 800
    end

    it 'should return 17.5% for dates between 3 and 10 years ago' do
      expect(VatRate.for_date(4.years.ago)).to eq 1750
    end

    it 'should return 22.25% for dates less than one year ago' do
      expect(VatRate.for_date(3.months.ago)).to eq 2225
    end

    it 'should raise exception for date before the first date in the database' do
      expect {
        VatRate.for_date(Date.new(1900, 7, 28))
      }.to raise_error VatRate::MissingVatRateError, 'There is no VAT rate for date 28/07/1900'
    end
  end

  describe '.pretty_rate' do
    it 'should return 8% for dates between 1 and 3 years ago' do
      expect(VatRate.pretty_rate(2.years.ago)).to eq '8%'
    end

    it 'should return 17.5% for dates between 3 and 10 years ago' do
      expect(VatRate.pretty_rate(4.years.ago)).to eq '17.5%'
    end

    it 'should return 22.25% for dates less than one year ago' do
      expect(VatRate.pretty_rate(3.months.ago)).to eq '22.25%'
    end
  end

  describe '.vat_amount' do
    context '22.25% VAT' do
      it 'should return 25.75 for 115.75' do
        vat_amount = VatRate.vat_amount(BigDecimal('115.75'), 6.months.ago)
        expect(vat_amount).to eq 25.75
      end

      it 'should return 25.76 for 115.76' do
        vat_amount = VatRate.vat_amount(BigDecimal('115.76'), 6.months.ago)
        expect(vat_amount).to eq 25.76
      end

      it 'should return 0 when calculate option is false' do
        vat_amount = VatRate.vat_amount(BigDecimal('100.00'), 6.months.ago, calculate: false)
        expect(vat_amount).to eq 0.0
      end
    end
  end

  describe '.rate_for_date' do
    it 'should be private' do
      VatRate.for_date(Date.today)
    end
  end
end
