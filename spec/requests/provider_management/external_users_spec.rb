require 'rails_helper'

RSpec.describe 'providers external users management', type: :request do
  describe 'GET /providers_management/providers/:provider_id/external_users/:id/disable' do
    subject(:disable_user) { get disable_provider_management_provider_external_user_path(provider, external_user) }
    let(:external_user) { create :external_user, provider: provider, user: create(:user, email: 'bubbletea@example.com') }
    let(:provider){ create :provider}

    before do
      sign_in user
    end

    context 'when not logged in' do
    end

    context 'when logged in as super admin' do
      let(:super_admin) { create :super_admin }
      let(:user) { super_admin.user }

      it 'marks the users email address as deleted' do
        expect{ disable_user }.to change{ external_user.reload.email }.from('bubbletea@example.com').to(/bubbletea@example.com.deleted/)
      end

      context 'when external user belongs to a different provider' do
        let(:external_user) { create :external_user, user: create(:user, email: 'bubbletea@example.com') }

        it 'does not mark the users email as deleted' do
          pending 'wip'
          expect{ disable_user }.not_to change{ external_user.reload.email }.from('bubbletea@example.com')
        end
      end

    end

    context 'when logged in as external user' do
      let(:other_external_user) { create :external_user }
      let(:user) { other_external_user.user }

      it 'does not mark the users email as deleted' do
        expect{ disable_user }.not_to change{ external_user.reload.email }.from('bubbletea@example.com')
      end
    end

    context 'when logged in as a caseworker' do
      let(:case_worker) { create :case_worker }
      let(:user) { case_worker.user }

      it 'does not mark the users email as deleted' do
        expect{ disable_user }.not_to change{ external_user.reload.email }.from('bubbletea@example.com')
      end
    end
  end
end
