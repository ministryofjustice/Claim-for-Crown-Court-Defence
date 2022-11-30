# frozen_string_literal: true

RSpec.describe 'User management' do
  describe 'index view' do
    subject do
      get users_path
      response
    end

    let(:user) { create(:user) }

    before { sign_in user }

    context 'when logged in as superadmin' do
      let(:user) { create(:super_admin).user }

      it { is_expected.to be_successful }
    end

    context 'when logged in a case worker' do
      let(:user) { create(:case_worker).user }

      it { is_expected.to redirect_to case_workers_root_path }
    end

    context 'when logged in an external user' do
      let(:user) { create(:external_user).user }

      it { is_expected.to redirect_to external_users_root_path }
    end

    context 'when user is not signed in' do
      before { sign_out user }

      it { is_expected.to redirect_to new_user_session_path }
    end
  end
end
