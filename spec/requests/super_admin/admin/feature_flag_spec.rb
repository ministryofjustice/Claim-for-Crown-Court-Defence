require 'rails_helper'

RSpec.describe 'Feature flag functionality', type: :request do
  let(:super_admin) { create :super_admin }
  let(:user) { super_admin.user }

  before { sign_in user }

  describe 'GET /super_admins/admin/settings' do
    let(:get_feature_flags_path) { get super_admins_admin_feature_flags_path }

    it 'renders successfully' do
      get_feature_flags_path
      expect(response).to have_http_status(:ok)
    end

    it 'displays title' do
      get_feature_flags_path
      expect(response.body).to include('Feature flags')
    end

    it 'shows new monarch feature' do
      get_feature_flags_path
      expect(response.body).to include('Enable new monarch')
    end

    context 'when not authenticated' do
      before { sign_out user }

      it 'redirects to log in' do
        get_feature_flags_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /admin/features' do
    let(:params) do
      {
        feature_flag: { enable_new_monarch: 'true' }
      }
    end
    let(:patch_feature_flags_path) { patch super_admins_admin_feature_flags_path, params: }

    it 'changes features value' do
      patch_feature_flags_path
      expect(FeatureFlag.enable_new_monarch?).to be true
    end

    it 'creates features if they do not exist' do
      expect { patch_feature_flags_path }.to change(FeatureFlag, :count).from(0).to(1)
    end

    it 'redirects to the same page' do
      patch_feature_flags_path
      expect(response).to redirect_to(super_admins_admin_feature_flags_path)
    end

    context 'when features already exist' do
      before { FeatureFlag.create! }

      it 'does not add another Setting object' do
        expect { patch_feature_flags_path }.not_to change(FeatureFlag, :count)
      end
    end

    context 'when not authenticated' do
      before { sign_out user }

      it 'redirects to log in' do
        patch_feature_flags_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
