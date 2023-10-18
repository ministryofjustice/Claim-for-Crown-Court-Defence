require 'rails_helper'

RSpec.describe DistanceCalculatorService::Directions do
  before do
    allow(DistanceCalculatorService::GoogleAPI).to receive(:new).and_return(OpenStruct.new(distances:))
  end

  describe '#max_distance' do
    subject { described_class.new('SW1A 1AA', 'SW1A 2AA').max_distance }

    context 'when there is a single route' do
      let(:distances) { [10_000] }

      it { is_expected.to eq 10_000 }
    end

    context 'when there are multiple routes' do
      let(:distances) { [10_000, 15_000, 12_000] }

      it { is_expected.to eq 15_000 }
    end

    context 'when there are no routes' do
      let(:distances) { [] }

      it { is_expected.to be_nil }
    end
  end
end
