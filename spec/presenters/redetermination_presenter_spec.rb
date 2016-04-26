require 'rails_helper'

describe RedeterminationPresenter do

  let(:claim)           { FactoryGirl.create :claim, apply_vat: true }
  let(:rd)              { FactoryGirl.create :redetermination, fees: 1452.33, expenses: 2455.77, disbursements: 2123.55, claim: claim }
  let(:presenter)       { RedeterminationPresenter.new(rd, view) }


  context 'currency fields' do
    it 'should format currency amount' do
      expect(presenter.fees_total).to eq '£1,452.33'
      expect(presenter.expenses_total).to eq '£2,455.77'
      expect(presenter.disbursements_total).to eq '£2,123.55'
      expect(presenter.total).to eq '£6,031.65'
      expect(presenter.vat_amount).to eq '£1,055.54'
      expect(presenter.total_inc_vat).to eq '£7,087.19'
    end
  end

end
