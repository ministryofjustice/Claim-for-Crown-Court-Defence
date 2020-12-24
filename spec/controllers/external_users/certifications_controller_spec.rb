require 'rails_helper'

RSpec.describe ExternalUsers::CertificationsController, type: :controller do
  let(:certification_type) { create(:certification_type) }
  let!(:advocate) { create(:external_user) }

  before { sign_in advocate.user }

  let(:claim) { create(:advocate_claim) }

  describe 'GET #new' do
    context 'claim is valid for submission' do
      before(:each) do
        get :new, params: { claim_id: claim.id }
      end

      it 'should return success' do
        expect(response.status).to eq 200
      end

      it 'should render new' do
        expect(response).to render_template(:new)
      end

      it 'should instantiate a new certification with pre-filled fields' do
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
        get :new, params: { claim_id: claim }
        expect(response).to redirect_to(external_users_claim_path(claim))
        expect(flash[:alert]).to eq 'Cannot certify a claim in submitted state'
      end
    end

    context 'claim not in a valid state' do
      it 'should redirect to the check your claim page with flash message' do
        claim = create(:claim, case_type_id: nil)
        get :new, params: { claim_id: claim }
        expect(response).to redirect_to(summary_external_users_claim_path(claim))
        expect(flash[:alert]).to eq 'Claim is not in a state to be submitted'
      end
    end
  end

  describe 'POST create' do
    context 'AGFS' do
      let(:claim) { create(:advocate_claim) }
      let(:sns_client) do
        Aws::SNS::Client.new(
            region: 'eu-west-1',
            stub_responses:
                {
                    publish: {}
                }
        )
      end

      before do
        allow(Aws::SNS::Client).to receive(:new).and_return sns_client
        allow(sns_client).to receive(:publish)
      end

      context 'claim not in a valid state' do
        let(:claim) { create(:claim, case_type_id: nil) }

        it 'should redirect to check your claim page with flash message' do
          post :create, params: valid_certification_params(claim, certification_type)
          expect(response).to redirect_to(summary_external_users_claim_path(claim))
          expect(flash[:alert]).to eq 'Claim is not in a state to be submitted'
        end
      end

      context 'valid certification params for submission' do
        let(:frozen_time) { Time.new(2018, 8, 20, 13, 54, 22) }

        it 'should be a redirect to confirmation' do
          post :create, params: valid_certification_params(claim, certification_type)
          expect(response).to redirect_to(confirmation_external_users_claim_path(claim))
        end

        it 'should change the state to submitted' do
          post :create, params: valid_certification_params(claim, certification_type)
          expect(claim.reload).to be_submitted
        end

        it 'should set the submitted at date' do
          travel_to(frozen_time) do
            post :create, params: valid_certification_params(claim, certification_type)
          end

          expect(claim.reload.last_submitted_at).to eq(frozen_time)
        end

        it 'notifies legacy importers' do
          expect(sns_client).to receive(:publish).once
          post :create, params: valid_certification_params(claim, certification_type)
        end

        context 'logging' do
          let(:logger) { double(Rails.logger) }
          before { allow(Rails).to receive(:logger).and_return logger }

          context 'on success' do
            it 'logs info of successful message sending' do
              expect(logger).to receive(:info).with(/Successfully sent message about submission of claim#/)
              post :create, params: valid_certification_params(claim, certification_type)
            end
          end

          context 'on failure' do
            before { allow(Aws::SNS::Client).to receive(:new).and_raise(StandardError, 'my unexpected SNS client error') }

            it 'logs warning of failed message sending' do
              expect(logger).to receive(:warn).with(/my unexpected SNS client error/)
              post :create, params: valid_certification_params(claim, certification_type)
            end
          end
        end
      end
    end

    context 'LGFS' do
      let(:claim) { create(:litigator_claim) }

      let(:sns_client) do
        Aws::SNS::Client.new(
          region: 'eu-west-1',
          stub_responses:
            {
              publish: {}
            }
        )
      end

      before do
        allow(Aws::SNS::Client).to receive(:new).and_return sns_client
        allow(sns_client).to receive(:publish)
      end

      it 'calls the SNS notification path' do
        post :create, params: valid_certification_params(claim, certification_type)
        expect(sns_client).to have_received(:publish).once
      end
    end

    context 'claim not in a valid state' do
      let(:claim) { create(:litigator_claim, case_type_id: nil) }

      it 'should redirect to check your claim page with flash message' do
        post :create, params: valid_certification_params(claim, certification_type)
        expect(response).to redirect_to(summary_external_users_claim_path(claim))
        expect(flash[:alert]).to eq 'Claim is not in a state to be submitted'
      end
    end

    context 'invalid certification' do
      it 'should redirect to new' do
        params = valid_certification_params(claim, certification_type)
        params['certification']['certification_type_id'] = 9999
        post :create, params: params
        expect(response).to render_template(:new)
        expect(assigns(:certification).errors.full_messages).to eq(['You must select one option on this form'])
      end
    end
  end

  describe 'PATCH #update' do
    it 'should redirect to claim path with a flash message' do
      claim = create(:advocate_claim)
      patch :update, params: { claim_id: claim }
      expect(response).to redirect_to(external_users_claim_path(claim))
      expect(flash[:alert]).to eq 'Cannot certify a claim in submitted state'
    end
  end
end

def valid_certification_params(claim, certification_type)
  certification_date = claim.created_at
  {
    'claim_id' => claim.id,
    'commit' => 'Certify and Submit Claim',
    'certification' => {
      'certification_type_id' => certification_type.id,
      'certified_by' => 'David Cameron',
      'main_hearing' => 'true',
      'certification_date_dd' => certification_date.day,
      'certification_date_mm' => certification_date.month,
      'certification_date_yyyy' => certification_date.year
    }
  }
end
