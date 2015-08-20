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
        expect(cert.certified_by).to eq ''
      end

     
    end
    
  end
end
