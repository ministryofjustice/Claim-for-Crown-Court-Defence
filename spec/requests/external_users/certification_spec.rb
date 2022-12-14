# frozen_string_literal: true

RSpec.describe 'Certification' do
  let(:advocate) { create(:external_user, :advocate) }
  let(:claim) { create(:advocate_final_claim) }
  let(:today_parts) { %i[dd mm yyyy].zip(Time.current.strftime('%-d-%-m-%Y').split('-')).to_h }

  describe 'POST #create' do
    let(:certification_params) do
      {
        'claim_id' => claim.id,
        'commit' => 'Certify and Submit Claim',
        'certification' => {
          'certification_type_id' => '1',
          'certified_by' => 'Joe Bloggs',
          'main_hearing' => 'true',
          'certification_date(3i)' => today_parts[:dd],
          'certification_date(2i)' => today_parts[:mm],
          'certification_date(1i)' => today_parts[:yyyy]
        }
      }
    end

    context 'when user is not signed in' do
      before do
        post external_users_claim_certification_path(claim.id), params: certification_params
      end

      it 'redirects to sign in page' do
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when user is signed in' do
      before do
        sign_in advocate.user
        post external_users_claim_certification_path(claim.id), params: certification_params
      end

      context 'with valid parameters' do
        it { expect(response).to be_redirect }
        it { expect(response).to redirect_to confirmation_external_users_claim_path(claim.id) }
      end

      context 'with invalid date part parameters' do
        let(:certification_params) do
          {
            'claim_id' => claim.id,
            'commit' => 'Certify and Submit Claim',
            'certification' => {
              'certification_type_id' => '1',
              'certified_by' => 'Joe Bloggs',
              'main_hearing' => 'true',
              'certification_date(3i)' => '32',
              'certification_date(2i)' => 'JAN',
              'certification_date(1i)' => '2021'
            }
          }
        end

        it { expect(response).to render_template(:new) }

        it 'displays date errors' do
          expect(response.body).to include('Enter certifying date')
        end
      end
    end
  end
end
