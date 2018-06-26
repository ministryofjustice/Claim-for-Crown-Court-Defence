require 'rails_helper'

RSpec.describe Expenses::TravelDistanceCalculator, type: :service do
  let(:supplier_number) { '9A999I' }
  let(:supplier_postcode) { 'MK40 3TN' }
  let!(:supplier) { create(:supplier_number, supplier_number: supplier_number, postcode: supplier_postcode) }
  let(:claim) { create(:litigator_claim, supplier_number: supplier_number) }
  let(:destination) { 'MK40 1HG' }
  let(:params) { { destination: destination } }

  subject(:service) { described_class.new(claim, params) }

  context 'but the associated claim does not exist' do
    let(:claim) { nil }

    it 'returns a failure result with the appropriate error code' do
      result = service.call

      expect(result).to be_failure
      expect(result.failure).to eq(:claim_not_found)
    end
  end

  context 'but the associated claim is not for LGFS' do
    let(:claim) { create(:advocate_claim) }

    it 'returns a failure result with the appropriate error code' do
      result = service.call

      expect(result).to be_failure
      expect(result.failure).to eq(:invalid_claim_type)
    end
  end

  context 'but the supplier associated with the claim does not have a postcode set' do
    let!(:supplier) { create(:supplier_number, supplier_number: supplier_number, postcode: nil) }

    it 'returns a failure result with the appropriate error code' do
      result = service.call

      expect(result).to be_failure
      expect(result.failure).to eq(:missing_origin)
    end
  end

  context 'but the destination was not provided' do
    let(:params) { { foo: 'bar' } }

    it 'returns a failure result with the appropriate error code' do
      result = service.call

      expect(result).to be_failure
      expect(result.failure).to eq(:missing_destination)
    end
  end

  context 'but the distance cannot be calculated' do
    it 'returns nil as the calculated distance' do
      expect(Maps::DistanceCalculator).to receive(:call).with(supplier_postcode, destination).and_return(nil)

      result = service.call

      expect(result).to be_success
      expect(result.value!).to be_nil
    end
  end

  it 'returns the calculated return distance value' do
    expect(Maps::DistanceCalculator).to receive(:call).with(supplier_postcode, destination).and_return(847)

    result = service.call

    expect(result).to be_success
    expect(result.value!).to eq(1694)
  end
end
