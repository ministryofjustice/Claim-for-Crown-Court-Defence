require 'rails_helper'

RSpec.describe ClaimSearchService::State do
  describe '#decorate' do
    subject(:decorate) { described_class.decorate(base, **params) }

    let(:base) { ClaimSearchService::Base.new }

    context 'when no status is given' do
      let(:params) { {} }

      it { is_expected.not_to be_a described_class }
    end

    context 'when the status is archived' do
      let(:params) { { status: 'archived' } }

      it { is_expected.to be_a described_class }
    end

    context 'when the status is allocated' do
      let(:params) { { status: 'allocated' } }

      it { is_expected.to be_a described_class }
    end

    context 'when no status is unknown' do
      let(:params) { { status: 'boo' } }

      it { is_expected.not_to be_a described_class }
    end
  end
end
