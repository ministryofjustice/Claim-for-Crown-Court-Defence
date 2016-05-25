require 'rails_helper'

describe Fee::WarrantFeePresenter do

  let(:warrant_fee) { instance_double(Fee::WarrantFee, claim: double) }
  let(:presenter) { Fee::WarrantFeePresenter.new(warrant_fee, view) }

  # DO NOT confuse Warrant Fees (XWAR) with Interim fees of warrant description/code (IWARR)
  context '#amount' do
    it 'should return fee amount as currency' do
      expect(warrant_fee).to receive(:amount).and_return 13.02
      expect(presenter.amount).to eq '£13.02'
    end
  end

  context '#rate' do
    it 'should call not_applicable' do
      expect(warrant_fee).to receive(:calculated?).and_return false
      expect(presenter).to receive(:not_applicable)
      presenter.rate
    end
  end

  context '#quantity' do
    it 'should call not_applicable' do
      expect(presenter).to receive(:not_applicable)
      presenter.quantity
    end
  end

end
