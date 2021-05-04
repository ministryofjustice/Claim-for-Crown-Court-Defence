require 'rails_helper'

RSpec.describe ClaimSearchService::State do
  describe '#decorate' do
    subject(:decorate) { described_class.decorate(base, **params) }

    let(:base) { ClaimSearchService::Base.new }

    context 'when no states are given' do
      let(:params) { {} }

      it { is_expected.not_to be_a described_class }
    end

    context 'when there is a single state' do
      let(:params) { { state: 'authorised' } }

      it { is_expected.to be_a described_class }
    end

    context 'when there are multiple states' do
      let(:params) { { state: %w[authorised part_authorised rejected] } }

      it { is_expected.to be_a described_class }
    end
  end
end
