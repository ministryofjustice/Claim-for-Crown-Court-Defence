require 'rails_helper'

RSpec.describe 'providers external users management' do
  include Capybara::RSpecMatchers

  describe 'viewing an external user' do
    let(:user) { create(:case_worker, :provider_manager).user }
    let(:external_user) { create(:external_user, provider:) }
    let(:provider) { create(:provider) }

    before do
      sign_in user
      get provider_management_provider_external_user_path(provider, external_user)
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eq(provider)
    end

    it 'assigns @external_user' do
      expect(assigns(:external_user)).to eq(external_user)
    end
  end

  describe 'viewing index of external users for a provider' do
    let(:user) { create(:case_worker, :provider_manager).user }
    let!(:external_user) { create(:external_user, provider:) }
    let(:provider) { create(:provider) }

    before do
      sign_in user
      get provider_management_provider_external_users_path(provider)
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eq(provider)
    end

    it 'assigns @external_users' do
      expect(assigns(:external_users)).to include(external_user)
    end
  end

  describe 'viewing the "find provider by email" page' do
    let(:user) { create(:case_worker, :provider_manager).user }

    before do
      sign_in user
      get provider_management_external_users_find_path
    end

    it 'returns http success' do
      expect(response).to be_successful
    end
  end

  describe 'searching for an external user by email' do
    subject { response }

    let(:user) { create(:case_worker, :provider_manager).user }
    let(:email) { searched_user.email }

    before do
      sign_in user
      post provider_management_external_users_find_path, params: { external_user: { email: } }
    end

    context 'when the email is for a provider' do
      let(:searched_user) { create(:external_user, :admin) }

      it do
        is_expected
          .to redirect_to(provider_management_provider_external_user_path(searched_user.provider, searched_user))
      end
    end

    context 'when the email is for a non-provider' do
      let(:searched_user) { create(:case_worker, :provider_manager) }

      it { is_expected.to redirect_to(provider_management_external_users_find_path) }
    end

    context 'when the email does not exist' do
      let(:email) { 'vail.email@does.not.exist.com' }

      it { is_expected.to redirect_to(provider_management_external_users_find_path) }
    end
  end

  describe 'viewing the new external user page' do
    let(:external_user) { ExternalUser.new(provider:).tap(&:build_user) }

    let(:user) { create(:case_worker, :provider_manager).user }
    let(:provider) { create(:provider) }

    before do
      sign_in user
      get new_provider_management_provider_external_user_path(provider)
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eq(provider)
    end

    # NOTE: use json comparison because we are not interested in
    #       whether the object is the same just that it creates a
    #       new one and builds its user
    it 'assigns @external_user' do
      expect(assigns(:external_user).to_json).to eq(external_user.to_json)
    end

    it 'builds user for @external_user' do
      expect(assigns(:external_user).user.to_json).to eq(external_user.user.to_json)
    end

    it 'renders the new template' do
      expect(response).to render_template(:new)
    end
  end

  describe 'creating a new external user' do
    def post_to_create_external_user_action(options = {})
      post provider_management_provider_external_users_path(provider), params: {
        external_user: {
          user_attributes: {
            email: 'foo@foobar.com', email_confirmation: 'foo@foobar.com',
            first_name: options[:valid] == false ? '' : 'john', last_name: 'Smith'
          },
          roles: ['advocate'], supplier_number: 'AB124'
        }
      }
    end

    let(:user) { create(:case_worker, :provider_manager).user }
    let(:provider) { create(:provider) }

    before do
      sign_in user
      get new_provider_management_provider_external_user_path(provider)
    end

    context 'when valid' do
      it 'creates an external_user' do
        expect { post_to_create_external_user_action }.to change(User, :count).by(1)
      end

      it 'redirects to external_users show view' do
        post_to_create_external_user_action
        expect(response).to redirect_to(provider_management_provider_external_user_path(provider, ExternalUser.last))
      end
    end

    context 'when invalid' do
      it 'does not create an external_user' do
        expect { post_to_create_external_user_action(valid: false) }.not_to change(User, :count)
      end

      it 'renders the new template' do
        post_to_create_external_user_action(valid: false)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'viewing the edit page for an external user' do
    let(:user) { create(:case_worker, :provider_manager).user }
    let(:external_user) { create(:external_user, provider:) }
    let(:provider) { create(:provider) }

    before do
      sign_in user
      get edit_provider_management_provider_external_user_path(provider, external_user)
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eq(provider)
    end

    it 'assigns @external_user' do
      expect(assigns(:external_user)).to eq(external_user)
    end

    it 'renders the template' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'updating an external user' do
    let(:user) { create(:case_worker, :provider_manager).user }
    let(:external_user) { create(:external_user, :admin, provider:) }
    let(:provider) { create(:provider) }

    before { sign_in user }

    context 'when valid' do
      let(:params) { { external_user: { supplier_number: 'XX100', roles: ['advocate'] } } }

      before { put provider_management_provider_external_user_path(provider, external_user), params: }

      it 'updates an external_user' do
        external_user.reload
        expect(external_user.reload.roles).to eq(['advocate'])
      end

      it 'redirects to external_users index' do
        expect(response).to redirect_to(provider_management_provider_external_user_path(provider, external_user))
      end
    end

    context 'when invalid' do
      let(:params) { { external_user: { roles: ['foo'] } } }

      before { put provider_management_provider_external_user_path(provider, external_user), params: }

      it 'does not update external_user' do
        external_user.reload
        expect(external_user.roles).to eq(['admin'])
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'viewing the change password page for an external user' do
    let(:user) { create(:case_worker, :provider_manager).user }
    let(:external_user) { create(:external_user, provider:) }
    let(:provider) { create(:provider) }

    before do
      sign_in user
      get change_password_provider_management_provider_external_user_path(provider, external_user)
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eq(provider)
    end

    it 'assigns @external_user' do
      expect(assigns(:external_user)).to eq(external_user)
    end

    it 'renders the change password template' do
      expect(response).to render_template(:change_password)
    end
  end

  describe 'changing the password for an external user' do
    subject(:password_update_request) do
      patch(
        update_password_provider_management_provider_external_user_path(external_user.provider, external_user),
        params:
      )
    end

    let(:params) do
      {
        external_user: {
          user_attributes: {
            password:,
            password_confirmation: password_confirm
          }
        }
      }
    end

    let(:user) { create(:case_worker, :provider_manager).user }
    let(:external_user) { create(:external_user) }

    let(:password) { 'password1234' }
    let(:password_confirm) { password }

    before do
      travel_to(6.months.ago) { external_user }
      sign_in user
    end

    context 'when valid' do
      it 'does not require current password to be successful in updating the user record' do
        expect { password_update_request }.to(change { external_user.reload.user.updated_at })
      end

      it 'redirects to external_user show action' do
        password_update_request
        expect(response)
          .to redirect_to(provider_management_provider_external_user_path(external_user.provider, external_user))
      end
    end

    context 'when invalid' do
      let(:password_confirm) { 'passwordxxx' }

      it 'does not update the user record' do
        expect { password_update_request }.not_to(change { external_user.reload.user.updated_at })
      end

      it 'renders the change password template' do
        password_update_request
        expect(response).to render_template(:change_password)
      end
    end
  end

  context 'when viewing change_availability pages' do
    subject(:change_availability) do
      get change_availability_provider_management_provider_external_user_path(provider, external_user)
    end

    let(:external_user) { create(:external_user, provider:) }
    let(:provider) { create(:provider) }

    before do
      sign_in user
      change_availability
    end

    context 'when logged in as advocate admin' do
      let(:other_external_user) { create(:external_user, :advocate_and_admin) }
      let(:user) { other_external_user.user }

      it { expect(response).to redirect_to external_users_root_path }
      it { expect(flash[:alert]).to eq('Unauthorised') }
    end

    context 'when logged in as super_admin with an enabled user' do
      let(:super_admin) { create(:super_admin) }
      let(:user) { super_admin.user }

      it { expect(response).to render_template(:change_availability) }
      it { expect(response.body).to have_content('Are you sure you want to disable') }
      it { expect(response.body).to have_button('Disable account') }
    end

    context 'when logged in as super_admin with a disabled user' do
      let(:super_admin) { create(:super_admin) }
      let(:user) { super_admin.user }
      let(:external_user) { create(:external_user, provider:).tap(&:disable) }

      it { expect(response).to render_template(:change_availability) }
      it { expect(response.body).to have_content('Are you sure you want to enable') }
      it { expect(response.body).to have_button('Enable account') }
    end
  end

  context 'when disabling the external_user' do
    subject(:disable_user) do
      patch update_availability_provider_management_provider_external_user_path(provider, external_user),
            params: { external_user: { availability: 'false' } }
    end

    let(:external_user) { create(:external_user, provider:) }
    let(:provider) { create(:provider) }

    before { sign_in user }

    context 'when not logged in' do
      let(:user) { create(:user) }

      before do
        sign_out user
        disable_user
      end

      it { expect(external_user).to be_enabled }
      it { expect(response).to redirect_to new_user_session_path }
      it { expect(flash[:alert]).to eq('Unauthorised') }
    end

    context 'when logged in as super admin' do
      let(:super_admin) { create(:super_admin) }
      let(:user) { super_admin.user }

      it { expect { disable_user }.to change { external_user.reload.enabled? }.from(true).to(false) }
      it { expect { disable_user }.to change { external_user.reload.disabled_at }.from(nil).to(be_a(Time)) }

      context 'when successfull response' do
        before { disable_user }

        it { expect(external_user.reload).to be_disabled }
        it { expect(response).to redirect_to provider_management_provider_external_user_path }
        it { expect(flash[:notice]).to eq('User successfully disabled') }
      end

      # TODO: is this behaviour needed? when would a external user ever be from another provider at this point
      context 'when enabled external user belongs to a different provider' do
        let(:external_user) { create(:external_user).tap(&:enable) }

        before { disable_user }

        it { expect(external_user.reload).to be_enabled }
        it { expect(response).to redirect_to provider_management_provider_external_user_path }
        it { expect(flash[:alert]).to eq('Unable to disable user') }
      end

      context 'when external user is already disabled' do
        before do
          external_user.disable
          disable_user
        end

        it { expect(external_user.reload).to be_disabled }
        it { expect(response).to redirect_to provider_management_provider_external_user_path }
        it { expect(flash[:alert]).to eq('Unable to disable user') }
      end
    end

    context 'when logged in as external user' do
      let(:other_external_user) { create(:external_user) }
      let(:user) { other_external_user.user }

      before { disable_user }

      it { expect(external_user.reload).to be_enabled }
      it { expect(response).to redirect_to external_users_root_path }
      it { expect(flash[:alert]).to eq('Unauthorised') }
    end

    context 'when logged in as a caseworker' do
      let(:case_worker) { create(:case_worker) }
      let(:user) { case_worker.user }

      before { disable_user }

      it { expect(external_user.reload).to be_enabled }
      it { expect(response).to redirect_to case_workers_root_path }
      it { expect(flash[:alert]).to eq('Unauthorised') }
    end
  end

  context 'when enabling the external_user' do
    subject(:enable_user) do
      patch update_availability_provider_management_provider_external_user_path(provider, external_user),
            params: { external_user: { availability: 'true' } }
    end

    let(:external_user) { create(:external_user, provider:).tap(&:disable) }
    let(:provider) { create(:provider) }

    before { sign_in user }

    context 'when not logged in' do
      let(:user) { create(:user) }

      before do
        sign_out user
        enable_user
      end

      it { expect(external_user.reload).to be_disabled }
      it { expect(response).to redirect_to new_user_session_path }
      it { expect(flash[:alert]).to eq('Unauthorised') }
    end

    context 'when logged in as super admin' do
      let(:super_admin) { create(:super_admin) }
      let(:user) { super_admin.user }

      it { expect { enable_user }.to change { external_user.reload.enabled? }.from(false).to(true) }
      it { expect { enable_user }.to change { external_user.reload.disabled_at }.from(be_a(Time)).to(nil) }

      context 'when successfull response' do
        before { enable_user }

        it { expect(external_user.reload).to be_enabled }
        it { expect(response).to redirect_to provider_management_provider_external_user_path }
        it { expect(flash[:notice]).to eq('User successfully enabled') }
      end

      # TODO: is this behaviour needed? when would a external user ever be from another provider at this point
      context 'when disabled external user belongs to a different provider' do
        let(:external_user) { create(:external_user).tap(&:disable) }

        before { enable_user }

        it { expect(external_user.reload).to be_disabled }
        it { expect(response).to redirect_to provider_management_provider_external_user_path }
        it { expect(flash[:alert]).to eq('Unable to enable user') }
      end

      context 'when external user is already enabled' do
        before do
          external_user.enable
          enable_user
        end

        it { expect(external_user.reload).to be_enabled }
        it { expect(response).to redirect_to provider_management_provider_external_user_path }
        it { expect(flash[:alert]).to eq('Unable to enable user') }
      end
    end

    context 'when logged in as another external user' do
      let(:other_external_user) { create(:external_user) }
      let(:user) { other_external_user.user }

      before { enable_user }

      it { expect(external_user).to be_disabled }
      it { expect(response).to redirect_to external_users_root_path }
      it { expect(flash[:alert]).to eq('Unauthorised') }
    end

    context 'when logged in as a caseworker' do
      let(:case_worker) { create(:case_worker) }
      let(:user) { case_worker.user }

      before { enable_user }

      it { expect(external_user.reload).to be_disabled }
      it { expect(response).to redirect_to case_workers_root_path }
      it { expect(flash[:alert]).to eq('Unauthorised') }
    end
  end
end
