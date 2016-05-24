require 'rails_helper'

describe Fee::MiscFeePresenter do

  let(:misc_fee) { instance_double(Fee::MiscFee, claim: double) }
  let(:presenter) { Fee::MiscFeePresenter.new(misc_fee, view) }

  context '#rate' do
    it 'should call not_applicable if child of LGFS claim' do
      allow(presenter).to receive(:agfs?).and_return false
      expect(presenter).to receive(:not_applicable)
      presenter.rate
    end

    it 'should return number as currency for calculated fees belonging to an AGFS claim' do
      allow(presenter).to receive(:agfs?).and_return true
      allow(misc_fee).to receive(:calculated?).and_return true
      expect(misc_fee).to receive(:rate).and_return 12.01
      expect(presenter.rate).to eq '£12.01'
    end

    it 'should return not_applicable for uncalculated fees belonging to an AGFS claim' do
      allow(presenter).to receive(:agfs?).and_return true
      allow(misc_fee).to receive(:calculated?).and_return false
      expect(presenter).to receive(:not_applicable)
      presenter.rate
    end
  end

  context '#quantity' do
    it 'should return fee quantity if child of AGFS claim' do
      allow(presenter).to receive(:agfs?).and_return true
      expect(misc_fee).to receive(:quantity)
      presenter.quantity
    end

    it 'should return not_applicable if child of LGFS claim' do
      allow(presenter).to receive(:agfs?).and_return false
      expect(presenter).to receive(:not_applicable)
      presenter.quantity
    end
  end

end
