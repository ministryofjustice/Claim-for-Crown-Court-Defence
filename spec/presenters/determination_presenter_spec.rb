require 'rails_helper'

describe DeterminationPresenter do
  let(:pt_version) { instance_double(PaperTrail::Version, item_type: 'Determination', changeset: changeset) }
  let(:presenter) { DeterminationPresenter.new(pt_version, view) }

  describe '#items' do
    context 'when changeset is complete without nil values' do
      let(:changeset) {
        {
          'fees' => [0.0, 1.0], 'expenses' => [0.0, 2.0], 'disbursements' => [0.0, 3.0], 'vat_amount' => [0.0, 1.5], 'total' => [0.0, 4.0]
        }
      }
      let(:expected_hash) {
        {
          'Fees' => 1.0, 'Expenses' => 2.0, 'Disbursements' => 3.0, 'Total (ex VAT)' => 4.0, 'VAT' => 1.5, 'Total (inc VAT)' => 5.5
        }
      }

      it 'should return a hash with expected values' do
        expect(presenter.items).to eq(expected_hash)
      end
    end

    context 'when changeset contains nil values' do
      let(:changeset) {
        {
          'fees' => [0.0, 1.0], 'expenses' => [0.0, nil], 'disbursements' => [0.0, 3.0], 'vat_amount' => [0.0, nil], 'total' => [0.0, 4.0]
        }
      }
      let(:expected_hash) {
        {
          'Fees' => 1.0, 'Expenses' => 0.0, 'Disbursements' => 3.0, 'Total (ex VAT)' => 4.0, 'VAT' => 0.0, 'Total (inc VAT)' => 4.0
        }
      }

      it 'should not fail when merging a changeset containing nil values' do
        expect(presenter.items).to eq(expected_hash)
      end
    end
  end
end
