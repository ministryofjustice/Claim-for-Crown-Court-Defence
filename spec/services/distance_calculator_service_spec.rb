require 'rails_helper'

RSpec.describe DistanceCalculatorService, type: :service do
  subject(:result) { described_class.call(claim, params) }

  let(:supplier_number) { '9A999I' }
  let(:supplier_postcode) { 'MK40 3TN' }
  let(:claim) { create(:litigator_claim, supplier_number:) }
  let(:destination) { 'MK40 1HG' }
  let(:params) { { destination: } }

  before do
    create(:supplier_number, supplier_number:, postcode: supplier_postcode)
    allow(described_class::Directions)
      .to receive(:new).with(supplier_postcode, destination).and_return(OpenStruct.new(max_distance: 847))
  end

  it 'is expected to have no error' do
    expect(result.error).to be_nil
  end

  it 'is expected to return double the route distance' do
    expect(result.value).to eq 1694
  end

  context 'when the associated claim does not exist' do
    let(:claim) { nil }

    it 'is expected to have a claim not found error' do
      expect(result.error).to eq :claim_not_found
    end
  end

  context 'when the associated claim is not for LGFS' do
    let(:claim) { create(:advocate_claim) }

    it 'is expected to have an invalid claim type error' do
      expect(result.error).to eq :invalid_claim_type
    end
  end

  context 'when the supplier associated with the claim does not have a postcode set' do
    let(:supplier_postcode) { nil }

    it 'is expected to have a missing origin error' do
      expect(result.error).to eq :missing_origin
    end
  end

  context 'when the destination was not provided' do
    let(:params) { { foo: 'bar' } }

    it 'is expected to have a missing destination error' do
      expect(result.error).to eq :missing_destination
    end
  end

  context 'when the destination is not a postcode' do
    let(:params) { { destination: 'London' } }

    it 'is expected to have an invalid destination error' do
      expect(result.error).to eq :invalid_destination
    end
  end

  context 'when the distance cannot be calculated' do
    before do
      allow(described_class::Directions)
        .to receive(:new).with(supplier_postcode, destination).and_return(OpenStruct.new(max_distance: nil))
    end

    it 'is expected to have no error' do
      expect(result.error).to be_nil
    end

    it 'is expected to have a nil distance' do
      expect(result.value).to be_nil
    end
  end
end
