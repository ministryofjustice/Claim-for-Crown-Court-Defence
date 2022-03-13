require 'rails_helper'

RSpec.describe 'providers external users management', type: :request do
  include Capybara::RSpecMatchers

  context 'when viewing change_availability pages' do
    subject(:change_availability) do
      get change_availability_provider_management_provider_external_user_path(provider, external_user)
    end

    let(:external_user) { create(:external_user, provider: provider) }
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
      let(:super_admin) { create :super_admin }
      let(:user) { super_admin.user }

      it { expect(response).to render_template(:change_availability) }
      it { expect(response.body).to have_content('Are you sure you want to disable') }
      it { expect(response.body).to have_button('Disable account') }
    end

    context 'when logged in as super_admin with a disabled user' do
      let(:super_admin) { create :super_admin }
      let(:user) { super_admin.user }
      let(:external_user) { create(:external_user, provider: provider).tap(&:disable) }

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

    let(:external_user) { create(:external_user, provider: provider) }
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
      it { expect { disable_user }.to change { external_user.reload.disabled_at }.from(nil).to(be_kind_of(Time)) }

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
      let(:other_external_user) { create :external_user }
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

    let(:external_user) { create(:external_user, provider: provider).tap(&:disable) }
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
      let(:super_admin) { create :super_admin }
      let(:user) { super_admin.user }

      it { expect { enable_user }.to change { external_user.reload.enabled? }.from(false).to(true) }
      it { expect { enable_user }.to change { external_user.reload.disabled_at }.from(be_kind_of(Time)).to(nil) }

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
