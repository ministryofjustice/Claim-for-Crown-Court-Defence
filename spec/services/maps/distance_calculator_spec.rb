require 'rails_helper'

RSpec.describe Maps::DistanceCalculator, type: :service do
  let(:options) { {} }

  describe '.call' do
    subject(:call) { described_class.call(origin, destination, options) }

    let(:options) { {} }

    context 'when a valid origin and destination are provided', vcr: { cassette_name: 'maps/valid_result' } do
      let(:origin) { 'SW1A 2BJ' }
      let(:destination) { 'MK40 1HG' }

      it { is_expected.to be_kind_of(Numeric) }
      it { is_expected.to be(118_943) }
    end

    context 'when an invalid origin is provided', vcr: { cassette_name: 'maps/invalid_origin_result' } do
      let(:origin) { 'A galaxy far far away' }
      let(:destination) { 'MK40 1HG' }

      it { is_expected.to be_nil }
    end

    context 'when an invalid destination is provided', vcr: { cassette_name: 'maps/invalid_destination_result' } do
      let(:origin) { 'SW1A 2BJ' }
      let(:destination) { 'A galaxy far far away' }

      it { is_expected.to be_nil }
    end
  end
end
