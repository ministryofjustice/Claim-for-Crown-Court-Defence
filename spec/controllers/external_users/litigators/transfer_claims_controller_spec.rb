require 'rails_helper'

RSpec.describe ExternalUsers::Litigators::TransferClaimsController, type: :controller do
  before { sign_in litigator.user }

  let!(:litigator)    { create(:external_user, :litigator) }
  let(:court)         { create(:court) }
  let(:offence)       { create(:offence, :miscellaneous) }
  let(:case_type)     { create(:case_type, :hsts) }
  let(:expense_type)  { create(:expense_type, :car_travel, :lgfs) }
  let(:external_user) { create(:external_user, :litigator, provider: litigator.provider) }
  let(:supplier_number) { litigator.provider.lgfs_supplier_numbers.first.supplier_number }

  describe 'GET #new' do
    before { get :new }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @claim' do
      expect(assigns(:claim)).to be_new_record
    end

    it 'assigns @claim to be a transfer claim' do
      expect(assigns(:claim)).to be_instance_of Claim::TransferClaim
    end

    it 'routes to litigators transfer new claim path' do
      expect(request.path).to eq('/litigators/transfer_claims/new')
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    render_views

    let(:params) do
      {
        'claim' => {
          'form_step' => 'transfer_fee_details',
          'form_id' => SecureRandom.uuid,
          'litigator_type' => 'original',
          'elected_case' => 'true',
          'transfer_stage_id' => '20',
          'transfer_date_dd' => '2',
          'transfer_date_mm' => '5',
          'transfer_date_yyyy' => '2016',
          'case_conclusion_id' => ''
        },
        'commit_continue' => 'Continue'
      }
    end

    context 'continue button pressed' do
      context 'valid params' do
        before(:each) { post :create, params: params }

        it 'creates a claim' do
          expect {
            params['claim']['form_id'] = SecureRandom.uuid
            post :create, params: params
          }.to change(Claim::TransferClaim, :count).by(1)
        end

        it 'saves claim as a draft' do
          expect(Claim::TransferClaim.last.state).to eq 'draft'
        end

        it 'redirects user to the next step' do
          claim = Claim::TransferClaim.last
          expect(response.status).to eq 302
          expect(response).to redirect_to edit_litigators_transfer_claim_path(claim, step: :case_details)
        end
      end

      context 'invalid params' do
        before(:each) do
          params['claim'].delete('litigator_type')
          post :create, params: params
        end

        it 'does not create a claim' do
          expect {
            params['claim']['form_id'] = SecureRandom.uuid
            post :create, params: params
          }.not_to change(Claim::TransferClaim, :count)
        end

        it 'returns success status' do
          expect(response.status).to eq 200
        end

        it 're-displays page 1 of form' do
          expect(response).to render_template('external_users/litigators/transfer_claims/new')
          expect(response).to render_template(partial: 'external_users/claims/transfer_fee/_detail_fields')
        end

        it 'claim contains errors' do
          expect(assigns(:claim).errors[:litigator_type]).to include('invalid')
          expect(assigns(:claim).errors[:transfer_detail]).to include('invalid_combo')
          expect(assigns(:claim).errors[:case_conclusion_id]).to include('invalid_combo')
        end
      end
    end

    context 'save as draft button pressed' do
      context 'valid_params' do
        before(:each) do
          params.delete('commit_continue')
          params['commit'] = 'Continue'
          post :create, params: params
        end

        it 'creates a claim' do
          expect {
            params['claim']['form_id'] = SecureRandom.uuid
            post :create, params: params
          }.to change(Claim::TransferClaim, :count).by(1)
        end

        it 'saves claim as a draft' do
          expect(Claim::TransferClaim.last.state).to eq 'draft'
        end

        it 'returns redirect status' do
          expect(response.status).to eq 302
        end

        it 'redirects to all claims page' do
          expect(response).to redirect_to(external_users_claims_path)
        end
      end

      context 'invalid params' do
        before(:each) do
          params.delete('commit_continue')
          params['claim'].delete('litigator_type')
          params['commit'] = 'Continue'
          post :create, params: params
        end

        it 'creates a claim' do
          expect {
            params['claim']['form_id'] = SecureRandom.uuid
            post :create, params: params
          }.to change(Claim::TransferClaim, :count).by(1)
        end

        it 'saves claim as a draft' do
          expect(Claim::TransferClaim.last.state).to eq 'draft'
        end

        it 'returns success status' do
          expect(response.status).to eq 302
        end

        it 'redirects to all claims page' do
          expect(response).to redirect_to(external_users_claims_path)
        end
      end
    end
  end

  describe 'PATCH #update' do
    render_views

    context 'update page 1' do
      let(:claim) { create :bare_bones_transfer_claim, creator: litigator }

      let(:page_1_params) do
        {
          'claim' => {
            'form_id' => SecureRandom.uuid,
            'form_step' => 'transfer_fee_details',
            'litigator_type' => 'original',
            'elected_case' => 'true',
            'transfer_stage_id' => '10',
            'transfer_date_dd' => '2',
            'transfer_date_mm' => '6',
            'transfer_date_yyyy' => '2016',
            'case_conclusion_id' => ''
          },
          'commit_continue' => 'Continue',
          'id' => claim.id.to_s
        }
      end

      it 'redirects user to next step' do
        put :update, params: page_1_params
        claim = Claim::TransferClaim.last
        expect(response.status).to eq 302
        expect(response).to redirect_to edit_litigators_transfer_claim_path(claim, step: :case_details)
      end

      it 'updates the claim details' do
        put :update, params: page_1_params
        expect(assigns(:claim).litigator_type).to eq 'original'
        expect(assigns(:claim).elected_case).to be true
        expect(assigns(:claim).transfer_stage_id).to eq 10
        expect(assigns(:claim).transfer_date).to eq Date.new(2016, 6, 2)
        expect(assigns(:claim).case_conclusion_id).to be_nil
      end
    end

    context 'update page 2' do
      let(:claim) { create :transfer_claim, creator: litigator }
      let(:court) { create :court }
      let(:offence) { create :offence }

      let(:page_2_params) do
        {
          'claim' => {
            'form_id' => claim.form_id,
            'form_step' => 'case_details',
            'supplier_number' => claim.provider.lgfs_supplier_numbers.first.supplier_number,
            'providers_ref' => 'PSR004',
            'court_id' => court.id.to_s,
            'case_number' => 'A20161234',
            'transfer_court_id' => '',
            'transfer_case_number' => '',
            'offence_id' => offence.id.to_s,
            'case_concluded_at_dd' => '2',
            'case_concluded_at_mm' => '10',
            'case_concluded_at_yyyy' => '2016',
            'defendants_attributes' => {
              '0' => {
                'first_name' => 'Stuart',
                'last_name' => 'HOLLANDS',
                'date_of_birth_dd' => '3',
                'date_of_birth_mm' => '7',
                'date_of_birth_yyyy' => '1988',
                'order_for_judicial_apportionment' => '0',
                'representation_orders_attributes' => {
                  '0' => {
                    'representation_order_date_dd' => '2',
                    'representation_order_date_mm' => '7',
                    'representation_order_date_yyyy' => '2015',
                    'maat_reference' => '2345678',
                    '_destroy' => 'false',
                    'id' => '115'
                  }
                },
                'id' => '100'
              }

            }
          },
          'offence_category' => {
            'description' => 'Abandonment of children under two'
          },
          'commit_continue' => 'Continue',
          'id' => '72'
        }
      end
    end
  end

  describe 'GET #edit' do
    let(:edit_request) { -> { get :edit, params: { id: claim } } }

    before { edit_request.call }

    context 'editable claim' do
      let(:claim) { create(:transfer_claim, creator: litigator) }

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'assigns @claim' do
        expect(assigns(:claim)).to eq(claim)
      end

      it 'claim is in the first submission step by default' do
        expect(assigns(:claim).form_step).to eq(claim.submission_stages.first.to_sym)
      end

      context 'when a step is provided' do
        let(:step) { :defendants }
        let(:edit_request) { -> { get :edit, params: { id: claim, step: step } } }

        it 'claim is submitted submission step' do
          expect(assigns(:claim).form_step).to eq(:defendants)
        end
      end

      it 'routes to litigators edit path' do
        expect(request.path).to eq edit_litigators_transfer_claim_path(claim)
      end

      it 'renders the template' do
        expect(response).to render_template(:edit)
      end
    end

    context 'uneditable claim' do
      let(:claim) do
        claim = create(:transfer_claim, creator: litigator)
        create(:transfer_detail, claim: claim)
        claim.submit!
        claim.allocate!
        claim
      end

      it 'redirects to the claims index' do
        expect(response).to redirect_to(external_users_claims_path)
      end
    end
  end

  describe 'PUT #update' do
    subject { create(:transfer_claim, creator: litigator) }

    context 'when valid' do
      context 'and deleting a rep order' do
        before {
          put :update,
              params: {
               id: subject,
               claim: {
                 defendants_attributes: {
                   '1' => {
                     id: subject.defendants.first,
                     representation_orders_attributes: {
                       '0' => {
                         id: subject.defendants.first.representation_orders.first,
                         _destroy: 1 }
                     }
                   }
                 }
               },
               commit_save_draft: 'Save to drafts'
              }
        }
        it 'reduces the number of associated rep orders by 1' do
          expect(subject.reload.defendants.first.representation_orders.count).to eq 1
        end
      end

      # context 'and editing an API created claim' do
      #   pending 'TODO: reimplement once/if transfer claim creation opened up to API'
      #
      #   before(:each) do
      #     subject.update(source: 'api')
      #   end
      #
      #   context 'and saving to draft' do
      #     before { put :update, id: subject, claim: { additional_information: 'foo' }, commit_save_draft: 'Save to drafts' }
      #     it 'sets API created claims source to indicate it is from API but has been edited in web' do
      #       expect(subject.reload.source).to eql 'api_web_edited'
      #     end
      #   end
      #
      #   context 'and submitted to LAA' do
      #     before { put :update, id: subject, claim: { additional_information: 'foo' }, summary: true, commit_submit_claim: 'Submit to LAA' }
      #     it 'sets API created claims source to indicate it is from API but has been edited in web' do
      #       expect(subject.reload.source).to eql 'api_web_edited'
      #     end
      #   end
      # end

      context 'and saving to draft' do
        it 'updates a claim' do
          put :update, params: { id: subject, claim: { additional_information: 'foo' }, commit_save_draft: 'Save to drafts' }
          subject.reload
          expect(subject.additional_information).to eq('foo')
        end

        it 'redirects to claims list path' do
          put :update, params: { id: subject, claim: { additional_information: 'foo' } }
          expect(response).to redirect_to(external_users_claims_path)
        end
      end

      context 'and submitted to LAA' do
        before do
          get :edit, params: { id: subject }
          put :update, params: { id: subject, claim: { additional_information: 'foo' }, summary: true, commit_submit_claim: 'Submit to LAA' }
        end

        it 'redirects to the claim summary page' do
          expect(response).to redirect_to(summary_external_users_claim_path(subject))
        end
      end
    end

    context 'when submitted to LAA and invalid ' do
      it 'does not set claim to submitted' do
        put :update, params: { id: subject, claim: { form_step: 'case_details', court_id: nil }, commit_submit_claim: 'Submit to LAA' }
        subject.reload
        expect(subject).to_not be_submitted
      end

      it 'renders edit template' do
        put :update, params: { id: subject, claim: { form_step: 'case_details', court_id: nil }, commit_submit_claim: 'Submit to LAA' }
        expect(response).to render_template(:edit)
      end
    end

    context 'Date Parameter handling' do
      it 'should transform dates with named months into dates' do
        put :update, params: { id: subject, claim: {
          'first_day_of_trial_yyyy' => '2015',
          'first_day_of_trial_mm' => 'jan',
          'first_day_of_trial_dd' => '4' }, commit_submit_claim: 'Submit to LAA' }
        expect(assigns(:claim).first_day_of_trial).to eq Date.new(2015, 1, 4)
      end

      it 'should transform dates with numbered months into dates' do
        put :update, params: { id: subject, claim: {
          'first_day_of_trial_yyyy' => '2015',
          'first_day_of_trial_mm' => '11',
          'first_day_of_trial_dd' => '4' }, commit_submit_claim: 'Submit to LAA' }
        expect(assigns(:claim).first_day_of_trial).to eq Date.new(2015, 11, 4)
      end
    end
  end
end
