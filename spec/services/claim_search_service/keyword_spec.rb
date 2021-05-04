require 'rails_helper'

RSpec.describe ClaimSearchService::Keyword do
  describe '#decorate' do
    subject(:decorate) { described_class.decorate(base, **params) }

    let(:base) { ClaimSearchService::Base.new }

    context 'when no status is given' do
      let(:params) { { search: 'T20200101' } }

      it { is_expected.not_to be_a described_class }
    end

    context 'when no search term is given' do
      let(:params) { { status: 'allocated' } }

      it { is_expected.not_to be_a described_class }
    end

    context 'when the status is allocated and there is a search term' do
      let(:params) { { status: 'archived', search: 'T20200101' } }

      it { is_expected.to be_a described_class }
    end

    context 'when no status is unknown' do
      let(:params) { { status: 'boo', search: 'T20200101' } }

      it { is_expected.not_to be_a described_class }
    end
  end
end
