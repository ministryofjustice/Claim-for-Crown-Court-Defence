require 'rails_helper'

RSpec.shared_examples 'attempting to add unclaimed fees while not logged in' do
  before { sign_out persona.user }

  it do
    add_fees
    expect(response).to redirect_to(new_user_session_url)
  end
end

RSpec.describe 'Adding unclaimed fees to claim' do
  subject(:add_fees) { post external_users_claim_fees_add_unclaimed_url(claim), params: }

  let(:persona) { create(:external_user) }
  let(:misc_fee) { create(:misc_fee_type, :miumu, :agfs_scheme_15) }
  let(:params) { { fees: [misc_fee.to_param] } }

  before do
    allow(claim).to receive(:eligible_misc_fee_types).and_return([misc_fee])

    sign_in persona.user
  end

  context 'when the claim is not eligible for the fee' do
    let(:claim) { create(:advocate_claim, :agfs_scheme_10, :with_graduated_fee_case) }

    it do
      add_fees
      expect(response).to have_http_status(:bad_request)
    end

    it { expect { add_fees }.not_to change(claim.fees, :count) }

    it_behaves_like 'attempting to add unclaimed fees while not logged in'
  end

  context 'when the claim is eligible for the fee and it has been claimed' do
    let(:claim) { create(:advocate_claim, :agfs_scheme_15, :with_graduated_fee_case) }

    before { claim.fees << build(:misc_fee, fee_type: misc_fee) }

    it do
      add_fees
      expect(response).to have_http_status(:bad_request)
    end

    it { expect { add_fees }.not_to change(claim.fees, :count) }

    it_behaves_like 'attempting to add unclaimed fees while not logged in'
  end

  context 'when the claim is eligible for the fee and it has not been claimed' do
    let(:claim) { create(:advocate_claim, :agfs_scheme_15, :with_graduated_fee_case) }

    it do
      add_fees
      expect(response).to have_http_status(:created)
    end

    it { expect { add_fees }.to change(claim.fees, :count).by(1) }

    it_behaves_like 'attempting to add unclaimed fees while not logged in'
  end
end
