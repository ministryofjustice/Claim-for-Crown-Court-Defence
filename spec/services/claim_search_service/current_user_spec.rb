require 'rails_helper'

RSpec.describe ClaimSearchService::CurrentUser do
  describe '#decorate' do
    subject(:decorate) { described_class.decorate(base, **params) }

    let(:base) { ClaimSearchService::Base.new }
    let(:user) { create :case_worker }

    context 'when no user is given' do
      let(:params) { { current_user_claims: true } }

      it { is_expected.not_to be_a described_class }
    end

    context 'when the current user claims flag is missing' do
      let(:params) { { user: user } }

      it { is_expected.not_to be_a described_class }
    end

    context 'when the user is present and the current user claims flag is false' do
      let(:params) { { user: user, current_user_claims: false } }

      it { is_expected.not_to be_a described_class }
    end

    context 'when the user is present and the current user claims flag is true' do
      let(:params) { { user: user, current_user_claims: true } }

      it { is_expected.to be_a described_class }
    end
  end
end
