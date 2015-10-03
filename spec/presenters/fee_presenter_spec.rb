require 'rails_helper'

RSpec.describe FeePresenter do

  let(:claim)         { create(:claim) }
  let(:fee_type)      { create(:fee_type, description: 'Basic fee type C') }
  let(:fee)           { create(:fee, quantity: 4, claim: claim, fee_type: fee_type) }


  describe '#dates_attended_delimited_string' do

    before {
      claim.fees.each do |fee|
        fee.dates_attended << create(:date_attended, attended_item: fee, date: Date.parse('21/05/2015'), date_to: Date.parse('23/05/2015'))
        fee.dates_attended << create(:date_attended, attended_item: fee, date: Date.parse('25/05/2015'), date_to: nil)
      end
    }

    it 'outputs string of dates or date ranges separated by comma' do
      claim.fees.each do |fee|
        fee = FeePresenter.new(fee, view)
        expect(fee.dates_attended_delimited_string).to eql('21/05/2015 - 23/05/2015, 25/05/2015')
      end
    end
  end

  describe 'amount' do
    it 'formats as currency' do
      fee.amount = 32456.3
      presenter = FeePresenter.new(fee, view)
      expect(presenter.amount).to eq '£32,456.30'
    end
  end

end
