require 'rails_helper'
require 'custom_matchers'

RSpec.describe ExternalUsers::CertificationsController, type: :controller, focus: true do
  let(:certification_type) { create(:certification_type) }
  let!(:advocate) { create(:external_user) }

  before { sign_in advocate.user }

  let(:claim) { create(:claim) }

  describe 'GET #new' do

    context 'claim is valid for submission' do
      before(:each) do
        get :new, {claim_id: claim.id}
      end

      it 'should return success' do
        expect(response.status).to eq 200
      end

      it 'should render new' do
        expect(response).to render_template(:new)
      end

      it 'should instantiate a new claim with pre-filled fields' do
        cert = assigns(:certification)
        expect(cert).to be_instance_of(Certification)
        expect(cert.claim_id).to eq claim.id
        expect(cert.certification_date). to eq(Date.today)
        expect(cert.certified_by).to eq advocate.name
      end
    end

    context 'claim already in submitted state' do
      it 'should redirect to claim path with a flash message' do
        claim = create(:submitted_claim)
        get :new, { claim_id: claim }
        expect(response).to redirect_to(external_users_claim_path(claim))
        expect(flash[:alert]).to eq 'Cannot certify a claim in submitted state'
      end
    end

    context 'claim not in a valid state' do
      it 'should redirect to edit page with flash message' do
        claim = create(:claim, case_type_id: nil)
        get :new, { claim_id: claim }
        expect(response).to redirect_to(edit_external_users_claim_path(claim))
        expect(flash[:alert]).to eq 'Claim is not in a state to be submitted'
      end
    end
  end

  describe 'POST create' do
    let(:claim) { create(:claim) }

    context 'valid certification params for submission' do
      let(:frozen_time) { Time.new(2015, 8, 20, 13, 54, 22) }

      it 'should be a redirect to confirmation' do
        post :create, valid_certification_params(claim, certification_type)
        expect(response).to redirect_to(confirmation_external_users_claim_path(claim))
      end

      it 'should change the state to submitted' do
        post :create, valid_certification_params(claim, certification_type)
        expect(claim.reload).to be_submitted
      end

      it 'should set the submitted at date' do
        Timecop.freeze(frozen_time) do
          post :create, valid_certification_params(claim, certification_type)
        end

        expect(claim.reload.last_submitted_at).to eq(frozen_time)
      end
    end

    context 'invalid certification' do
      it 'should redirect to new' do
        params = valid_certification_params(claim, certification_type)
        params['certification']['certification_type_id'] = 99
        post :create, params
        expect(response).to render_template(:new)
        expect(assigns(:certification).errors.full_messages).to eq(['You must select one option on this form'])
      end
    end
  end
end


def valid_certification_params(claim, certification_type)
  {
    'claim_id'      => claim.id,
    'commit'        => "Certify and Submit Claim",
    'certification' => {
      'certification_type_id'            => certification_type.id,
      'certified_by'                     => 'David Cameron',
      'main_hearing'                     => 'true',
      'certification_date_dd'            => '20',
      'certification_date_mm'            => '08',
      'certification_date_yyyy'          => '2015'
    }
  }
end
