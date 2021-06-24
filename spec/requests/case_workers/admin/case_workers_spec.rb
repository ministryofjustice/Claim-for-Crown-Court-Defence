RSpec.describe 'Caseworker admin', type: :request do
  let(:admin) { create(:case_worker, :admin) }

  before { sign_in admin.user }

  describe 'POST /case_workers/admin/case_workers' do
    let(:create_case_workers_request) { post(case_workers_admin_case_workers_path, params: case_worker_params) }

    context 'when valid' do
      let(:case_worker_params) {
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
      }

      it 'creates a case_worker' do
        expect { create_case_workers_request }.to change(User, :count).by(1)
      end

      it 'redirects to case workers index' do
        create_case_workers_request
        expect(response).to redirect_to(case_workers_admin_case_workers_url)
      end

      it 'attempts to deliver an email' do
        expect(DeviseMailer).to receive(:reset_password_instructions)
        create_case_workers_request
      end

      describe 'if there is an issue with delivering the email' do
        let(:mailer) { double DeviseMailer }

        before do
          allow(DeviseMailer).to receive(:reset_password_instructions).and_raise(NoMethodError)
        end

        it 'raises an error' do
          expect(Rails.logger).to receive(:error).with(/DEVISE MAILER ERROR: 'NoMethodError' while sending reset password mail/)
          create_case_workers_request
        end
      end
    end

    context 'when invalid' do
      let(:case_worker_params) { { case_worker: { roles: ['case_worker'], user_attributes: { email: 'invalidemail' } } } }

      it 'does not create a case worker' do
        expect { create_case_workers_request }.to_not change(User, :count)
      end

      it 'renders the new template' do
        create_case_workers_request
        expect(response).to render_template(:new)
      end
    end
  end
end