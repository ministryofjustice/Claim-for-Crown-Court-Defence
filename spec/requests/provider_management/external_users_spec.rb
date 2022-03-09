require 'rails_helper'

RSpec.describe 'providers external users management', type: :request do
  context 'when disabling the external_user' do
    subject(:disable_user) do
      patch update_availability_provider_management_provider_external_user_path(provider, external_user),
            params: { external_user: { availability: 'false' } }
    end

    let(:external_user) do
      create :external_user, provider: provider, user: create(:user, email: 'bubbletea@example.com')
    end

    let(:provider) { create :provider }

    before { sign_in user }

    context 'when not logged in' do
      let(:user) { create(:user) }

      before { sign_out user }

      it 'does not mark the users email as deleted' do
        expect { disable_user }.not_to change { external_user.reload.email }.from('bubbletea@example.com')
      end
    end

    context 'when logged in as super admin' do
      let(:super_admin) { create :super_admin }
      let(:user) { super_admin.user }

      it 'marks the users email address as deleted' do
        expect { disable_user }
          .to change { external_user.reload.email }
          .from('bubbletea@example.com')
          .to("bubbletea@example.com.deleted.#{external_user.user.id}")
      end

      context 'when external user belongs to a different provider' do
        let(:external_user) { create :external_user, user: create(:user, email: 'bubbletea@example.com') }

        it 'does not mark the users email as deleted' do
          expect { disable_user }.not_to change { external_user.reload.email }.from('bubbletea@example.com')
        end
      end

      context 'when external user is already deleted' do
        before do
          external_user.soft_delete
        end

        it 'does not mark the users email as deleted a second time' do
          expect { disable_user }
            .not_to change { external_user.reload.email }
            .from("bubbletea@example.com.deleted.#{external_user.user.id}")
        end
      end
    end

    context 'when logged in as external user' do
      let(:other_external_user) { create :external_user }
      let(:user) { other_external_user.user }

      it 'does not mark the users email as deleted' do
        expect { disable_user }.not_to change { external_user.reload.email }.from('bubbletea@example.com')
      end
    end

    context 'when logged in as a caseworker' do
      let(:case_worker) { create :case_worker }
      let(:user) { case_worker.user }

      it 'does not mark the users email as deleted' do
        expect { disable_user }.not_to change { external_user.reload.email }.from('bubbletea@example.com')
      end
    end
  end

  context 'when enabling the external_user' do
    subject(:enable_user) do
      patch update_availability_provider_management_provider_external_user_path(provider, external_user),
            params: { external_user: { availability: 'true' } }
    end

    let(:external_user) do
      create(:external_user, provider: provider, user: create(:user, email: 'bubbletea@example.com')).tap(&:soft_delete)
    end

    let(:provider) { create :provider }

    before { sign_in user }

    context 'when not logged in' do
      let(:user) { create(:user) }

      before { sign_out user }

      it 'does not mark the users email as deleted' do
        expect { enable_user }
          .not_to change { external_user.reload.email }
          .from("bubbletea@example.com.deleted.#{external_user.user.id}")
      end
    end

    context 'when logged in as super admin' do
      let(:super_admin) { create :super_admin }
      let(:user) { super_admin.user }

      it 'marks the users email address as enabled' do
        expect { enable_user }
          .to change { external_user.reload.email }
          .from("bubbletea@example.com.deleted.#{external_user.user.id}")
          .to('bubbletea@example.com')
      end

      it 'sets the external_user.deleted_at time stamp to nil' do
        expect { enable_user }.to change { external_user.reload.deleted_at }.to nil
      end

      it 'sets the external_user.user.deleted_at time stamp to nil' do
        expect { enable_user }.to change { external_user.reload.user.deleted_at }.to nil
      end

      context 'when external user belongs to a different provider' do
        let(:external_user) do
          create(:external_user, user: create(:user, email: 'bubbletea@example.com')).tap(&:soft_delete)
        end

        it 'does not mark the users email as enabled' do
          expect { enable_user }
            .not_to change { external_user.reload.email }
            .from("bubbletea@example.com.deleted.#{external_user.user.id}")
        end
      end

      context 'when external user is already deleted' do
        let(:external_user) do
          create(:external_user, provider: provider, user: create(:user, email: 'bubbletea@example.com'))
        end

        it 'does not change the email' do
          expect { enable_user }
            .not_to change { external_user.reload.email }
            .from('bubbletea@example.com')
        end
      end
    end

    context 'when logged in as external user' do
      let(:other_external_user) { create :external_user }
      let(:user) { other_external_user.user }

      it 'does not mark the users email as deleted' do
        expect { enable_user }
          .not_to change { external_user.reload.email }
          .from("bubbletea@example.com.deleted.#{external_user.user.id}")
      end
    end

    context 'when logged in as a caseworker' do
      let(:case_worker) { create :case_worker }
      let(:user) { case_worker.user }

      it 'does not mark the users email as deleted' do
        expect { enable_user }
          .not_to change { external_user.reload.email }
          .from("bubbletea@example.com.deleted.#{external_user.user.id}")
      end
    end
  end
end
