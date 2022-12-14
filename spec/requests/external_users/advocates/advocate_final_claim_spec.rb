# frozen_string_literal: true

RSpec.describe 'Advocate final claims' do
  let(:advocate) { create(:external_user, :advocate) }
  let!(:case_type) { create(:case_type, :trial) }
  let!(:court) { create(:court) }

  describe 'GET #new' do
    context 'when user is not signed in' do
      before do
        get new_advocates_claim_path
      end

      it 'redirects to sign in page' do
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when user is signed in' do
      before do
        sign_in advocate.user
        get new_advocates_claim_path
      end

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'assigns @claim' do
        expect(assigns(:claim)).to be_new_record
      end

      it 'assigns @claim to be an advocate final claim' do
        expect(assigns(:claim)).to be_instance_of Claim::AdvocateClaim
      end

      it 'assigns @case_types' do
        expect(assigns(:case_types)).to all(be_a(CaseType))
      end

      it 'renders the template' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST #create' do
    before do
      sign_in advocate.user
      post advocates_claims_path, params: case_details_params
    end

    context 'when on case_details form step' do
      let(:case_details_params) do
        {
          'claim' => {
            'form_id' => SecureRandom.uuid, # not actually needed for test
            'form_step' => 'case_details', # not actually needed as is the default
            'providers_ref' => 'T20215555/1',
            'case_type_id' => case_type.id,
            'court_id' => court.id,
            'case_number' => 'A20181234',
            'first_day_of_trial(3i)' => '1',
            'first_day_of_trial(2i)' => '1',
            'first_day_of_trial(1i)' => '2021',
            'trial_concluded_at(3i)' => '1',
            'trial_concluded_at(2i)' => '10',
            'trial_concluded_at(1i)' => '2021',
            'estimated_trial_length' => '5',
            'actual_trial_length' => '6'
          },
          'commit_continue' => ''
        }
      end

      context 'with valid params' do
        let(:claim) { Claim::BaseClaim.find_by(providers_ref: 'T20215555/1') }

        it 'redirects' do
          expect(response).to be_redirect
        end

        it 'redirects to defendants form step' do
          expect(response).to redirect_to edit_advocates_claim_path(claim, step: 'defendants')
        end
      end

      context 'with invalid date params' do
        let(:case_details_params) do
          {
            'claim' => {
              'form_id' => SecureRandom.uuid, # not actually needed for test
              'form_step' => 'case_details', # not actually needed as is the default
              'providers_ref' => 'T20215555/1',
              'case_type_id' => case_type.id,
              'court_id' => court.id,
              'case_number' => 'A20181234',
              'first_day_of_trial(3i)' => '32',
              'first_day_of_trial(2i)' => 'JAN',
              'first_day_of_trial(1i)' => '2021',
              'trial_concluded_at(3i)' => '1',
              'trial_concluded_at(2i)' => '10',
              'trial_concluded_at(1i)' => '2021',
              'estimated_trial_length' => '5',
              'actual_trial_length' => '6'
            },
            'commit_continue' => ''
          }
        end

        it 'renders new' do
          expect(response).to render_template(:new)
        end

        it 'displays date error' do
          expect(response.body).to include('Enter a date for the first day of trial')
        end
      end
    end
  end

  describe 'GET #edit' do
    let(:claim) { create(:advocate_final_claim, external_user: advocate) }

    context 'when user is signed in' do
      before do
        get edit_advocates_claim_path(claim)
      end

      it 'redirects to sign in page' do
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when user is an advocate' do
      before do
        sign_in advocate.user
        get edit_advocates_claim_path(claim)
      end

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'assigns @claim to be an advocate final claim' do
        expect(assigns(:claim)).to be_instance_of Claim::AdvocateClaim
      end

      it 'assigns @case_types' do
        expect(assigns(:case_types)).to all(be_a(CaseType))
      end

      it 'renders the template' do
        expect(response).to render_template(:edit)
      end
    end
  end
end
