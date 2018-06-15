require 'rails_helper'

RSpec.describe SupplierNumberPresenter do
  let(:account_number) { '3N677Q' }
  let(:postcode) { 'W3A 7RG' }
  let(:supplier_number) { build(:supplier_number, supplier_number: account_number, postcode: postcode) }

  subject(:presenter) { described_class.new(supplier_number, view) }

  describe '#supplier_label' do
    it 'returns a label including the supplier number and its postcode' do
      expect(presenter.supplier_label).to eq("#{account_number} (#{postcode})")
    end

    context 'when the supplier does not have a defined postcode' do
      let(:postcode) { nil }

      it 'returns a label including only the supplier number' do
        expect(presenter.supplier_label).to eq(account_number)
      end
    end
  end
end
