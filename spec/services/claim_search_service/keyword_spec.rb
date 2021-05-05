require 'rails_helper'

RSpec.describe ClaimSearchService::Keyword do
  describe '#decorate' do
    subject(:decorate) { described_class.decorate(base, **params) }

    let(:base) { ClaimSearchService::Base.new }

    context 'when no search term is given' do
      let(:params) { {} }

      it { is_expected.not_to be_a described_class }
    end

    context 'when a search term is provided' do
      let(:params) { { term: 'T20200101' } }

      it { is_expected.to be_a described_class }
    end
  end
end
