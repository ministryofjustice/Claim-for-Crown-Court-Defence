require 'rails_helper'

RSpec.describe 'providers external users management', type: :request do
  context 'when viewing change_availability pages' do
    subject(:change_availability) do
      get change_availability_provider_management_provider_external_user_path(provider, external_user)
    end

    let(:external_user) do
      create :external_user, provider: provider, user: create(:user, email: 'bubbletea@example.com')
    end

    let(:provider) { create :provider }

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

      it { expect(response).to render_template(:disable_confirmation) }
    end

    context 'when logged in as super_admin with a disabled user' do
      let(:super_admin) { create :super_admin }
      let(:user) { super_admin.user }

      let(:external_user) do
        create(:external_user,
               provider: provider,
               user: create(:user, email: 'bubbletea@example.com')).tap(&:soft_delete)
      end

      it { expect(response).to render_template(:enable_confirmation) }
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

      before { sign_out user }

      it { expect { disable_user }.not_to change { external_user.reload.enabled? }.from(true) }
    end

    context 'when logged in as super admin' do
      let(:super_admin) { create(:super_admin) }
      let(:user) { super_admin.user }

      it { expect { disable_user }.to change { external_user.reload.enabled? }.from(true).to(false) }
      it { expect { disable_user }.to change { external_user.reload.disabled_at }.from(nil).to(be_kind_of(Time)) }

      # TODO: check - is provider memdership matching relevant? how would a unique external user ever be in an unmatching provider?
      context 'when external user belongs to a different provider' do
        let(:external_user) { create(:external_user) }

        it { expect { disable_user }.not_to change { external_user.reload.enabled? }.from(true) }
      end

      # is this needed? should we instead be testing that the disabled_at timestamp is not changed?
      context 'when external user is already disabled' do
        before { external_user.disable }

        it { expect { disable_user }.not_to change { external_user.reload.enabled? }.from(false) }
      end
    end

    context 'when logged in as external user' do
      let(:other_external_user) { create :external_user }
      let(:user) { other_external_user.user }

      it { expect { disable_user }.not_to change { external_user.reload.enabled? }.from(true) }
    end

    context 'when logged in as a caseworker' do
      let(:case_worker) { create :case_worker }
      let(:user) { case_worker.user }

      it { expect { disable_user }.not_to change { external_user.reload.enabled? }.from(true) }
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

      before { sign_out user }

      it { expect { enable_user }.not_to change { external_user.reload.enabled? }.from(false) }
    end

    context 'when logged in as super admin' do
      let(:super_admin) { create :super_admin }
      let(:user) { super_admin.user }

      it { expect { enable_user }.to change { external_user.reload.enabled? }.from(false).to(true) }
      it { expect { enable_user }.to change { external_user.reload.disabled_at }.from(be_kind_of(Time)).to(nil) }

      # TODO: check - is provider memdership matching relevant? how would a unique external user ever be in an unmatching provider?
      context 'when external user belongs to a different provider' do
        let(:external_user) { create(:external_user).tap(&:disable) }

        it { expect { enable_user }.not_to change { external_user.reload.enabled? }.from(false) }
      end

      # is this needed? is it just to avoid unneccessary updates?
      context 'when external user is already enabled' do
        let(:external_user) { create(:external_user, provider: provider) }

        it { expect { enable_user }.not_to change { external_user.reload.enabled? }.from(true) }
      end
    end

    context 'when logged in as external user' do
      let(:other_external_user) { create :external_user }
      let(:user) { other_external_user.user }

      it { expect { enable_user }.not_to change { external_user.reload.enabled? }.from(false) }
    end

    context 'when logged in as a caseworker' do
      let(:case_worker) { create :case_worker }
      let(:user) { case_worker.user }

      it { expect { enable_user }.not_to change { external_user.reload.enabled? }.from(false) }
    end
  end
end
