RSpec.describe 'Caseworker admin', type: :request do
  let(:admin) { create(:case_worker, :admin) }

  before { sign_in admin.user }

  describe 'POST /case_workers/admin/case_workers' do
    let(:create_case_workers_request) { post(case_workers_admin_case_workers_path, params: case_worker_params) }

    context 'when valid' do
      let(:case_worker_params) do
        {
          case_worker: {
            user_attributes: {
              email: 'foo@foobar.com',
              password: 'password',
              password_confirmation: 'password',
              first_name: 'John',
              last_name: 'Smith'
            },
            roles: ['case_worker'],
            location_id: create(:location).id
          }
        }
      end

      it 'creates a case_worker' do
        expect { create_case_workers_request }.to change(User, :count).by(1)
      end

      it 'redirects to case workers index' do
        create_case_workers_request
        expect(response).to redirect_to(case_workers_admin_case_workers_url)
      end

      it 'attempts to deliver an email' do
        allow(DeviseMailer).to receive(:reset_password_instructions)
        create_case_workers_request
        expect(DeviseMailer).to have_received(:reset_password_instructions)
      end

      describe 'if there is an issue with delivering the email' do
        let(:mailer) { instance_double DeviseMailer }

        before do
          allow(DeviseMailer).to receive(:reset_password_instructions).and_raise(NoMethodError)
        end

        it 'raises an error' do
          allow(Rails.logger).to receive(:error)
          create_case_workers_request
          expect(Rails.logger).to have_received(:error)
            .with(/DEVISE MAILER ERROR: 'NoMethodError' while sending reset password mail/)
        end
      end
    end

    context 'when invalid' do
      let(:case_worker_params) do
        { case_worker: { roles: ['case_worker'], user_attributes: { email: 'invalidemail' } } }
      end

      it 'does not create a case worker' do
        expect { create_case_workers_request }.not_to change(User, :count)
      end

      it 'renders the new template' do
        create_case_workers_request
        expect(response).to render_template(:new)
      end
    end
  end
end
