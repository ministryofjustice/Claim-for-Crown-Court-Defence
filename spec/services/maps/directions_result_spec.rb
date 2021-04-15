require 'rails_helper'

RSpec.describe Maps::DirectionsResult, type: :model do
  let(:response) {
    VCR.use_cassette('maps/valid_result') do |cassette|
      interaction = cassette.serializable_hash['http_interactions'][0]
      @json_result = JSON.parse(interaction['response']['body']['string'])
    end
    @json_result['routes']
  }
  subject(:result) { described_class.new(response) }

  describe '#distances' do
    context 'when the provided response does not have any routes' do
      let(:response) { [] }

      it { expect(result.distances).to be_empty }
    end

    it 'returns all the distances for all the available routes' do
      expect(result.distances).to match_array([95808, 118943, 95104])
    end
  end

  describe '#max_distance' do
    context 'when the provided response does not have any routes' do
      let(:response) { [] }

      it { expect(result.max_distance).to be_nil }
    end

    it 'returns the max distance out of the available routes' do
      expect(result.max_distance).to eq(118943)
    end
  end
end
