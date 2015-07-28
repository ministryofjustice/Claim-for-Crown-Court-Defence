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

describe VatRate do

  before(:all) do
    FactoryGirl.create :vat_rate, effective_date: 1.year.ago, rate_base_points: 2225
    FactoryGirl.create :vat_rate, effective_date: 10.years.ago, rate_base_points: 1750
  end

  after(:all) do
    VatRate.destroy_all
  end

  describe '.for_date' do
    it 'should return 17.5% for dates between 1 and 10 years ago' do
      expect(VatRate.for_date(2.years.ago)).to eq 1750
    end

    it 'should return 22.25% for dates less than one year ago' do
      expect(VatRate.for_date(3.months.ago)).to eq 2225
    end

    it 'should raise exception for date before the first date in the database' do
      expect {
        VatRate.for_date(Date.new(2003, 7, 28))
      }.to raise_error VatRate::MissingVatRateError, "There is no VAT rate for date 28/07/2003"
    end
  end
 

  
end
