require 'rails_helper'
# See https://developers.google.com/maps/documentation/directions/get-directions for example responses from the
# Google Directions API

RSpec.describe DistanceCalculatorService::GoogleAPI do
  let(:returned_status) { 'OK' }
  let(:returned_routes) { [] }

  before do
    stub_request(:get, %r{maps.google.com/maps/api/directions/json})
      .to_return(status: 200, body: { status: returned_status, routes: returned_routes }.to_json)
  end

  describe '#distances' do
    subject(:distances) { described_class.new('SW1A 1AA', 'SW1A 2AA').distances }

    context 'when one route is returned' do
      let(:returned_routes) { [{ legs: [{ distance: { value: 10_000, text: '6.2 mi' } }] }] }

      it { is_expected.to eq([10_000]) }
    end

    context 'when multiple routes are returned' do
      let(:returned_routes) do
        [
          { legs: [{ distance: { value: 10_000, text: '6.2 mi' } }] },
          { legs: [{ distance: { value: 15_000, text: '9.3 mi' } }] },
          { legs: [{ distance: { value: 12_000, text: '7.5 mi' } }] }
        ]
      end

      it { is_expected.to eq([10_000, 15_000, 12_000]) }
    end

    context 'when a route is missing any legs' do
      let(:returned_routes) do
        [
          { legs: [{ distance: { value: 10_000, text: '6.2 mi' } }] },
          {},
          { legs: [{ distance: { value: 12_000, text: '7.5 mi' } }] }
        ]
      end

      it { is_expected.to eq([10_000, 12_000]) }
    end

    context 'when a leg is missing a distance' do
      let(:returned_status) { 'OK' }
      let(:returned_routes) do
        [
          { legs: [{ distance: { value: 10_000, text: '6.2 mi' } }] },
          { legs: [{}] },
          { legs: [{ distance: { value: 12_000, text: '7.5 mi' } }] }
        ]
      end

      it { is_expected.to eq([10_000, 12_000]) }
    end

    context 'when a location could not be found' do
      let(:returned_status) { 'NOT_FOUND' }
      let(:returned_routes) { [] }

      it { is_expected.to eq([]) }
    end

    context 'when no routes are returned' do
      let(:returned_status) { 'ZERO_RESULTS' }
      let(:returned_routes) { [] }

      it { is_expected.to eq([]) }
    end

    context 'when the limit of API calls has been exceeded' do
      let(:returned_status) { 'OVER_QUERY_LIMIT' }
      let(:returned_routes) { [] }

      it { is_expected.to eq([]) }
    end

    context 'when the request has been denied' do
      let(:returned_status) { 'REQUEST_DENIED' }
      let(:returned_routes) { [] }

      it { is_expected.to eq([]) }
    end

    context 'when there was an unknown error' do
      let(:returned_status) { 'UNKNOWN_ERROR' }
      let(:returned_routes) { [] }

      it { is_expected.to eq([]) }
    end

    context 'when the request fails' do
      before do
        stub_request(:get, %r{maps.google.com/maps/api/directions/json}).to_return(status: 500)
      end

      it { is_expected.to eq([]) }
    end
  end
end
