require 'rails_helper'

RSpec.describe Claim::AdvocateClaimPresenter do
  subject(:presenter) { described_class.new(claim, view) }
  let(:claim) { create(:advocate_claim) }

  it { is_expected.to be_instance_of(Claim::AdvocateClaimPresenter) }
  it { is_expected.to be_kind_of(Claim::BaseClaimPresenter) }

  specify { expect(presenter.can_have_expenses?).to be_truthy }
  specify { expect(presenter.can_have_disbursements?).to be_falsey }

  describe '#requires_interim_claim_info?' do
    subject { presenter.requires_interim_claim_info? }

    before { seed_fee_schemes }

    context 'when claim is pre agfs reform' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_9) }
      it { is_expected.to be_falsey }
    end

    context 'when claim is post agfs reform' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_10) }
      it { is_expected.to be_truthy }
    end
  end
end
