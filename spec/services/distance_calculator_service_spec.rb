require 'rails_helper'

RSpec.describe DistanceCalculatorService, type: :service do
  subject(:service) { described_class.new(claim, params) }

  let(:supplier_number) { '9A999I' }
  let(:supplier_postcode) { 'MK40 3TN' }
  let(:claim) { create(:litigator_claim, supplier_number: supplier_number) }
  let(:destination) { 'MK40 1HG' }
  let(:params) { { destination: destination } }

  before { create(:supplier_number, supplier_number: supplier_number, postcode: supplier_postcode) }

  context 'when the associated claim does not exist' do
    let(:claim) { nil }

    it 'returns a failure result with the appropriate error code' do
      result = service.call

      expect(result).to be_failure
      expect(result.failure).to eq(:claim_not_found)
    end
  end

  context 'when the associated claim is not for LGFS' do
    let(:claim) { create(:advocate_claim) }

    it 'returns a failure result with the appropriate error code' do
      result = service.call

      expect(result).to be_failure
      expect(result.failure).to eq(:invalid_claim_type)
    end
  end

  context 'when the supplier associated with the claim does not have a postcode set' do
    let(:supplier_postcode) { nil }

    it 'returns a failure result with the appropriate error code' do
      result = service.call

      expect(result).to be_failure
      expect(result.failure).to eq(:missing_origin)
    end
  end

  context 'when the destination was not provided' do
    let(:params) { { foo: 'bar' } }

    it 'returns a failure result with the appropriate error code' do
      result = service.call

      expect(result).to be_failure
      expect(result.failure).to eq(:missing_destination)
    end
  end

  context 'when the destination is not a postcode' do
    let(:params) { { destination: 'London' } }

    it 'returns a failure result with the appropriate error code' do
      result = service.call

      expect(result).to be_failure
      expect(result.failure).to eq(:invalid_destination)
    end
  end

  context 'when the distance cannot be calculated' do
    it 'returns nil as the calculated distance' do
      expect(DistanceCalculatorService::Directions)
        .to receive(:call).with(supplier_postcode, destination).and_return(nil)

      result = service.call

      expect(result).to be_success
      expect(result.value!).to be_nil
    end
  end

  it 'returns the calculated return distance value' do
    expect(DistanceCalculatorService::Directions)
      .to receive(:call).with(supplier_postcode, destination).and_return(847)

    result = service.call

    expect(result).to be_success
    expect(result.value!).to eq(1694)
  end
end
