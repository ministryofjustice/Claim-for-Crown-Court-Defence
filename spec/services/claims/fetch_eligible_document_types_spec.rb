require 'rails_helper'

RSpec.describe Claims::FetchEligibleDocumentTypes do
  subject(:document_types) { described_class.for(claim) }

  context 'when claim is for LGFS' do
    let(:claim) { build(:litigator_claim) }

    it 'returns all the available document types' do
      expect(document_types).to eq(DocType.all)
    end
  end

  context 'when claim is for AGFS final' do
    let(:claim) { build(:advocate_claim) }

    it 'returns all the available document types' do
      expect(document_types).to eq(DocType.all)
    end
  end

  context 'when claim is for AGFS final' do
    let(:claim) { build(:advocate_interim_claim) }

    it 'returns a subset of the document types that apply to the new fee reform' do
      expect(document_types).to eq(DocType.for_fee_reform)
    end
  end
end
