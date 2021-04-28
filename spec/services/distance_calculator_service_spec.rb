require 'rails_helper'

RSpec.configure do |config|
  config.before(:each, gmaps_directions_with_alternatives: true) do
    stub_request(:get, %r{https://maps.googleapis.com/maps/api/directions/json\?.*})
      .to_return(
        status: 200,
        body: read_stub('google_maps-directions/valid_response_with_alternatives'),
        headers: { 'Content-Type' => 'application/json; charset=utf-8' }
      )
  end

  config.before(:each, gmaps_directions_invalid_origin: true) do
    stub_request(:get, %r{https://maps.googleapis.com/maps/api/directions/json\?.*})
      .to_return(
        status: 200,
        body: status_invalid_origin_request,
        headers: { 'Content-Type' => 'application/json; charset=utf-8' }
      )
  end

  def read_stub(file_name)
    File.read("./spec/fixtures/stubs/#{file_name}.json")
  end

  def status_invalid_origin_request
    <<~JSON
      {
        "error_message": "Invalid request. Missing the 'origin' parameter.",
        "routes": [],
        "status": "INVALID_REQUEST"
      }
    JSON
  end
end

RSpec.describe DistanceCalculatorService, type: :service do
  subject(:result) { described_class.call(claim, params) }

  let(:supplier_number) { '9A999I' }
  let(:supplier_postcode) { 'MK40 3TN' }
  let(:claim) { create(:litigator_claim, supplier_number: supplier_number) }
  let(:destination) { 'MK40 1HG' }
  let(:params) { { destination: destination } }

  before do
    create(:supplier_number, supplier_number: supplier_number, postcode: supplier_postcode)
  end

  context 'with valid claim and params', gmaps_directions_with_alternatives: true do
    let(:expected_uri) do
      'https://maps.googleapis.com/maps/api/directions/json?alternatives=true&destination=MK40 1HG&key=not-a-real-api-key&origin=MK40 3TN&region=uk'
    end

    let(:destination) { 'MK40 1HG' }

    it 'returns result with nil error' do
      expect(result.error).to be_nil
    end

    it 'sends request to expected directions API' do
      result
      expect(a_request(:get, expected_uri)).to have_been_made.once
    end

    it 'returns double the maximum route distance' do
      expect(result.value).to eq 432624
    end
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

  context 'when the distance cannot be calculated', gmaps_directions_invalid_origin: true do
    subject(:result) { instance.call }

    let(:instance) { described_class.new(claim, params) }

    before { allow(instance).to receive(:log) }

    it 'returns result with nil error' do
      expect(result.error).to be_nil
    end

    it 'returns result with nil value' do
      expect(result.value).to be_nil
    end

    it 'logs google maps directions error' do
      result
      expect(instance)
        .to have_received(:log)
        .with(action: :distance,
              error: kind_of(GoogleMaps::Directions::Error),
              level: :error)
    end
  end
end
