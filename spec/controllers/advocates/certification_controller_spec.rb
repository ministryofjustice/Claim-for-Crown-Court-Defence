require 'rails_helper'
require 'custom_matchers'

RSpec.describe Advocates::CertificationsController, type: :controller, focus: true do
  let!(:advocate) { create(:advocate) }

  before { sign_in advocate.user }

  let(:claim)             { FactoryGirl.create :claim }

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
        claim = FactoryGirl.create :submitted_claim
        get :new, {claim_id: claim.id}
        expect(response).to redirect_to(advocates_claim_path(claim))
        expect(flash[:alert]).to eq 'Cannot certify a claim in submitted state'
      end
    end

    context 'claim not in a valid state' do
      it 'should redirect to edit page with flash message' do
        claim = FactoryGirl.create :claim, case_type_id: nil
        get :new, {claim_id: claim.id}
        expect(response).to redirect_to(edit_advocates_claim_path(claim))
        expect(flash[:alert]).to eq 'Claim is not in a state to be submitted'
      end
    end
  end

  describe 'POST create' do

    let(:claim)                   { FactoryGirl.create :claim }

    context 'valid certification params for submission' do


      let(:frozen_time)             { Time.new(2015, 8, 20, 13, 54, 22) }

      it 'should be a redirect to confirmation' do
        post :create, valid_certification_params(claim)
        expect(response).to redirect_to(confirmation_advocates_claim_path(claim))
      end

      it 'should change the state to submitted' do
        post :create, valid_certification_params(claim)
        reloaded_claim = Claim.find claim.id
        expect(reloaded_claim).to be_submitted
      end

      it 'should set the submitted at date' do
        Timecop.freeze(frozen_time) do
          post :create, valid_certification_params(claim)
          reloaded_claim = Claim.find claim.id
          expect(reloaded_claim.last_submitted_at.to_time).to eq frozen_time
        end
      end
    end

    context 'invalid certification' do
      it 'should redirect to new' do
        params = valid_certification_params(claim)
        params['certification']['notified_court'] = '1'
        post :create, params
        expect(response).to render_template(:new)
        expect(assigns(:certification).errors.full_messages).to eq( [ 'You must check one and only one checkbox on this form'] )
      end
    end
  end
end


def valid_certification_params(claim)
  {
    'claim_id'      => claim.id,
    'commit'        => "Certify and Submit Claim",
    'certification' => {
      'main_hearing'                     => '1',
      'notified_court'                   => '0',
      'attended_pcmh'                    => '0',
      'attended_first_hearing'           => '0',
      'previous_advocate_notified_court' => '0',
      'fixed_fee_case'                   => '0',
      'certified_by'                     => 'David Cameron',
      "certification_date_dd"            => "20",
      "certification_date_mm"            => "08",
      "certification_date_yyyy"          => "2015"
    }
  }
end

