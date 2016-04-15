require 'rails_helper'

RSpec.describe Fee::MiscFeeTypePresenter do

  let(:fee_type)  { build :misc_fee_type }
  let(:presenter) { described_class.new(fee_type, view) }

  describe '#data_attributes' do
    context 'case_numbers' do
      it 'returns false when it is not Case uplift' do
        expect(presenter.data_attributes[:case_numbers]).to be_falsey
      end

      it 'returns true when is Case uplift' do
        fee_type.code = 'XUPL'
        expect(presenter.data_attributes[:case_numbers]).to be_truthy
      end
    end
  end
end
