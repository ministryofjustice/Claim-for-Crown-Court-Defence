require 'rails_helper'

describe Fee::GraduatedFeePresenter do

  let(:grad_fee) { instance_double(Fee::GraduatedFee, claim: double) }
  let(:presenter) { Fee::GraduatedFeePresenter.new(grad_fee, view) }

  context '#rate' do
    it 'should call not_applicable ' do
      expect(presenter).to receive(:not_applicable)
      presenter.rate
    end
  end

  context '#quantity' do
    it 'should return fee quantity' do
      expect(grad_fee).to receive(:quantity).and_return 12
      expect(presenter.quantity).to eq 12
    end
  end

end
