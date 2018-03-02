require 'rails_helper'

RSpec.describe 'external_users/claim_types/selection.html.haml', type: :view do

  include ViewSpecHelper

  before(:each) do
    initialize_view_helpers(view)
  end

  context 'claim type options' do
    context 'when logged in as AGFS/LGFS admin' do
      let(:external_user) { create(:external_user, :agfs_lgfs_admin) }

      before do
        sign_in(external_user.user)
        assign(:available_fee_schemes, %w(agfs lgfs_final lgfs_interim lgfs_transfer))
        render
      end

      it "should include advocate fee, litigator final, interim and transfer fee options" do
        expect(response.body).to include("Advocate fees")
        expect(response.body).to include("Litigator final fee")
        expect(response.body).to include("Litigator interim fee")
        expect(response.body).to include("Litigator transfer fee")
      end

      it "should default to selecting Advocate fees" do
        expect(response.body).to have_checked_field(:scheme_chosen_agfs)
      end
    end

    context 'when logged in as litigator' do
      let(:external_user) { create(:external_user, :litigator) }

      before do
        sign_in(external_user.user)
        assign(:available_fee_schemes, %w(lgfs_final lgfs_interim lgfs_transfer))
        render
      end

      it "should include litigator final, interim and transfer fee options only" do
        expect(response.body).not_to include("Advocate fees")
        expect(response.body).to include("Litigator final fee")
        expect(response.body).to include("Litigator interim fee")
        expect(response.body).to include("Litigator transfer fee")
      end

      it "should default to selecting Litigator final fee" do
        expect(response.body).to have_checked_field(:scheme_chosen_lgfs_final)
      end
    end

    context 'when logged in as advocate' do
      let(:external_user) { create(:external_user, :advocate) }

      before do
        sign_in(external_user.user)
        assign(:available_fee_schemes, %w(agfs))
        render
      end

      it "should include advocate fee options only" do
        expect(response.body).to include("Advocate fees")
        expect(response.body).not_to include("Litigator final fee")
        expect(response.body).not_to include("Litigator interim fee")
        expect(response.body).not_to include("Litigator transfer fee")
      end
    end
  end

end
