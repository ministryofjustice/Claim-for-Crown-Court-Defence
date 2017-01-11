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

  context '#warrant_issued_date' do
    it 'returns formatted date' do
      expect(warrant_fee).to receive(:warrant_issued_date).and_return(Date.new(2017, 1, 11))
      expect(presenter.warrant_issued_date).to eq '11/01/2017'
    end
  end

  context '#warrant_executed_date' do
    it 'returns formatted date' do
      expect(warrant_fee).to receive(:warrant_executed_date).and_return(Date.new(2016, 8, 3))
      expect(presenter.warrant_executed_date).to eq '03/08/2016'
    end
  end

  context '#warrant_executed?' do
    it 'returns true if date present' do
      expect(warrant_fee).to receive(:warrant_executed_date).and_return(Date.new(2016, 8, 3))
      expect(presenter.warrant_executed?).to be true
    end

    it 'returns true if date present' do
      expect(warrant_fee).to receive(:warrant_executed_date).and_return(nil)
      expect(presenter.warrant_executed?).to be false
    end
  end

end
