require 'rails_helper'

describe Fee::TransferFeePresenter do

  let(:transfer_fee) { instance_double(Fee::TransferFee, claim: double) }
  let(:presenter) { Fee::TransferFeePresenter.new(transfer_fee, view) }

  context '#rate' do
    it 'should call not_applicable when fee belongs to and LGFS claim' do
      expect(presenter).to receive(:not_applicable)
      presenter.rate
    end
  end

end
