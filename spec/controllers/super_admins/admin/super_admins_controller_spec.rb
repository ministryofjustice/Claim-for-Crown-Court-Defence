require 'rails_helper'

RSpec.describe SuperAdmins::Admin::SuperAdminsController do
  let(:super_admin) { create(:super_admin) }

  subject { super_admin }

  before { sign_in subject.user }

  describe 'GET #show' do
    before { get :show, params: { id: subject } }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @super_admin' do
      expect(assigns(:super_admin)).to eq(subject)
    end
  end

  describe 'GET #edit' do
    before { get :edit, params: { id: subject } }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @super_admin' do
      expect(assigns(:super_admin)).to eq(subject)
    end

    it 'renders the edit template' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'GET #change_password' do
    before { get :change_password, params: { id: subject } }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @super_admin' do
      expect(assigns(:super_admin)).to eq(subject)
    end

    it 'renders the change password template' do
      expect(response).to render_template(:change_password)
    end
  end

  describe 'PUT #update_password' do
    before do
      subject.user.update(password: 'PasswordForTest', password_confirmation: 'PasswordForTest')
      sign_in subject.user # need to sign in again after password change
    end

    context 'when valid' do
      before { put :update_password, params: { id: subject, super_admin: { user_attributes: { current_password: 'PasswordForTest', password: 'password5678', password_confirmation: 'password5678' } } } }

      it 'redirects to super admin show action' do
        expect(response).to redirect_to(super_admins_admin_super_admin_path(subject))
      end
    end

    context 'when mandatory params for super admin are not provided' do
      it 'raises a paramenter missing error' do
        expect {
          put :update_password, params: { id: subject, super_admin: {} }
        }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context 'when invalid' do
      it 'renders the change password template' do
        put :update_password, params: { id: subject, super_admin: { user_attributes: { foo: 'bar' } } }
        expect(response).to render_template(:change_password)
      end
    end
  end

  describe 'PUT #update' do
    before do
      put :update, params: { id: subject, super_admin: { user_attributes: { first_name: 'Joshua', last_name: 'Dude', password: 'PasswordForTest', email: 'superadmin@bigblackhhole.com' } } }
    end

    context 'when valid' do
      it 'updates a super admin' do
        subject.reload
        expect(subject.reload.user.first_name).to eq('Joshua')
      end

      it 'redirects to super admin show page' do
        expect(response).to redirect_to(super_admins_admin_super_admin_path(subject))
      end

      it 'displays a success message' do
        expect(flash[:notice]).to eq('Super Administrator successfully updated')
      end
    end

    context 'when invalid' do
      before do
        put :update, params: { id: subject, super_admin: { user_attributes: { first_name: '' } } }
      end

      it 'does not update super admin' do
        subject.reload
        expect(subject.user.first_name).to eq('Joshua')
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end
end
