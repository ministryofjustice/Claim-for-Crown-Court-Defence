require 'rails_helper'

RSpec.describe ClaimSearchService::ValueBand do
  describe '#decorate' do
    subject(:decorate) { described_class.decorate(base, **params) }

    let(:base) { ClaimSearchService::Base.new }

    context 'when no value band id is given' do
      let(:params) { {} }

      it { is_expected.not_to be_a described_class }
    end

    context 'when the value band id is 0' do
      let(:params) { { value_band_id: 0 } }

      it { is_expected.not_to be_a described_class }
    end

    context 'when the value band id is 10' do
      let(:params) { { value_band_id: 10 } }

      it { is_expected.to be_a described_class }
    end
  end
end
