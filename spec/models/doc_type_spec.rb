require 'rails_helper'

RSpec.describe DocType do
  describe '.for_fee_reform' do
    subject(:doc_types) { described_class.for_fee_reform }

    specify { expect(doc_types.map(&:id)).to contain_exactly(1, 3, 4, 6) }
  end

  describe '.find' do
    it 'returns a DocTypeInstance with the specified id' do
      dti = DocType.find(4)
      expect(dti.id).to eq 4
      expect(dti.name).to eq 'Copy of the indictment'
    end

    it 'raises if no record with that id is found' do
      expect {
        DocType.find(888)
      }.to raise_error ArgumentError, 'No DocType with id 888'
    end
  end

  describe '.find_by_ids' do
    it 'returns a list of matching ids in id order when ids given as a list' do
      doctypes = DocType.find_by_ids(5, 9, 1, 44)
      expect(doctypes.map(&:id)).to eq([5, 1, 9])
    end

    it 'returns a list of matching ids in sequence order when ids given as an array' do
      doctypes = DocType.find_by_ids([5, 9, 1, 44])
      expect(doctypes.map(&:id)).to eq([5, 1, 9])
    end

    it 'returns an empty array if no matching ids' do
      doctypes = DocType.find_by_ids(99, 188)
      expect(doctypes).to be_empty
    end
  end
end
