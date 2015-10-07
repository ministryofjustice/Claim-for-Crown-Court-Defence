require 'rails_helper'

RSpec.describe ClaimIntentionsController, type: :controller do
  let!(:advocate)       { create(:advocate) }
  before { sign_in advocate.user }

  describe 'POST #create' do
    context 'when form_id present' do
      it 'should create a Claim Intention' do
        expect{
          post :create, claim_intention: { form_id: SecureRandom.uuid }
        }.to change(ClaimIntention, :count).by(1)
      end
    end

    context 'when form_id not present' do
      it 'should not create a Claim Intention' do
        expect{
          post :create, claim_intention: { form_id: nil }
        }.to_not change(ClaimIntention, :count)
      end
    end
  end
end
