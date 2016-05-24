require 'rails_helper'

describe Fee::WarrantFeePresenter do

  let(:war_fee) { instance_double(Fee::WarrantFee, claim: double) }
  let(:presenter) { Fee::WarrantFeePresenter.new(war_fee, view) }

  context '#amount' do
    it 'should call not_applicable ' do
      expect(presenter).to receive(:not_applicable)
      presenter.amount
    end
  end

  context '#rate' do
    it 'should call not_applicable' do
      expect(war_fee).to receive(:calculated?).and_return false
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
