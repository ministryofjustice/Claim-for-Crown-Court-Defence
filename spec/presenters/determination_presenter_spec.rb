require 'rails_helper'

RSpec.describe DeterminationPresenter do
  let(:changeset) { {} }
  let(:pt_version) { instance_double(PaperTrail::Version, item_type: 'Determination', changeset: changeset, event: 'my_event', created_at: DateTime.parse('2019-03-31 09:38:00.000000')) }
  let(:presenter) { DeterminationPresenter.new(pt_version, view) }

  describe '#event' do
    it 'sends message to version#event' do
      expect(pt_version).to receive(:event)
      expect(presenter.event).to eql 'my_event'
    end
  end

  describe '#timestamp' do
    it 'sends message to version#created_at' do
      expect(pt_version).to receive(:created_at)
      presenter.timestamp
    end

    it 'returns string formatted time' do
      expect(presenter.timestamp).to eql '09:38'
    end
  end

  describe '#itemise' do
    let(:changeset) do
      {
        'fees' => [0.0, 1.0],
        'expenses' => [0.0, 2.0],
        'disbursements' => [0.0, 3.0],
        'vat_amount' => [0.0, 1.5],
        'total' => [0.0, 4.0]
      }
    end

    it 'successively yields attribute and new value to block' do
      expect { |block|
        presenter.itemise(&block)
      }.to yield_successive_args(['Fees', 1.0],
                                 ['Expenses', 2.0],
                                 ['Disbursements', 3.0],
                                 ['Total (ex VAT)', 4.0],
                                 ['VAT', 1.5],
                                 ['Total (inc VAT)', 5.5])
    end
  end

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
