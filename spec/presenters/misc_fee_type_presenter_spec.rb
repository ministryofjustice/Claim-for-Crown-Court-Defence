require 'rails_helper'

# TODO: no misc fees are case uplifts any longer, remove whole class and spec
RSpec.describe Fee::MiscFeeTypePresenter do
  let(:fee_type)  { build :misc_fee_type }
  let(:presenter) { described_class.new(fee_type, view) }

  describe '#data_attributes' do
    context 'case_numbers' do
      it 'returns false when it is not Case uplift' do
        expect(presenter.data_attributes[:case_numbers]).to be_falsey
      end

      it 'returns true when is Case uplift' do
        allow(fee_type).to receive(:case_uplift?).and_return true
        expect(presenter.data_attributes[:case_numbers]).to be_truthy
      end
    end
  end
end
