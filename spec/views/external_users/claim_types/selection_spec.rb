require 'rails_helper'

describe 'external_users/claim_types/selection.html.haml', type: :view do

  include ViewSpecHelper

  before(:each) do
    initialize_view_helpers(view)
  end

  context 'claim type options' do
    context 'when logged in as AGFS/LGFS admin' do

      before do
        assign(:claim_types, [Claim::AdvocateClaim,Claim::LitigatorClaim,Claim::InterimClaim])
        render
      end
      it "should include advocate fee, litigator final fee and litigator interim fee options only" do
        expect(response.body).to include("Advocate fees")
        expect(response.body).to include("Litigator final fee")
        expect(response.body).to include("Litigator interim fee")
      end
    end

    context 'when logged in as litigator' do
      before do
        assign(:claim_types, [Claim::LitigatorClaim,Claim::InterimClaim])
        render
      end
      it "should include litigator final and litigator interim fee options only" do
        expect(response.body).not_to include("Advocate fees")
        expect(response.body).to include("Litigator final fee")
        expect(response.body).to include("Litigator interim fee")
      end
    end

    context 'when logged in as advocate' do
      before do
        assign(:claim_types, [Claim::AdvocateClaim])
        render
      end
      it "should include advocate fee options only" do
        expect(response.body).to include("Advocate fees")
        expect(response.body).not_to include("Litigator final fee")
        expect(response.body).not_to include("Litigator interim fee")
      end
    end
  end

end
