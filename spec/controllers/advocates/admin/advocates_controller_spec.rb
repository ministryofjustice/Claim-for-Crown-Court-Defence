require 'rails_helper'

RSpec.describe Advocates::Admin::AdvocatesController, type: :controller do
  let(:chamber) { create(:chamber) }
  let(:admin) { create(:advocate, :admin, chamber: chamber) }

  subject { create(:advocate, chamber: chamber) }

  before { sign_in admin.user }

  describe "GET #index" do

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns @advocates' do
      advocate = create(:advocate, chamber: admin.chamber)
      other_chamber_advocate = create(:advocate)
      get :index
      expect(assigns(:advocates)).to match_array([admin, advocate])
    end

    it 'renders the template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    before { get :show, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @advocate' do
      expect(assigns(:advocate)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:show)
    end
  end

  describe "GET #new" do
    before { get :new }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @advocate' do
      expect(assigns(:advocate)).to be_new_record
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    before { get :edit, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @advocate' do
      expect(assigns(:advocate)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:edit)
    end
  end

  describe "GET #change_password" do
    before { get :change_password, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @advocate' do
      expect(assigns(:advocate)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:change_password)
    end
  end

  describe "POST #create" do
    context 'when valid' do
      it 'creates a advocate' do
        expect {
          post :create, advocate: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'password', first_name: 'John', last_name: 'Smith' },
                                    role: 'advocate',
                                    supplier_number: 'AB124' }
        }.to change(User, :count).by(1)
      end

      it 'redirects to advocates index' do
        post :create, advocate: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'password', first_name: 'John', last_name: 'Smith'},
                                  role: 'advocate',
                                  supplier_number: 'XY123'  }
        expect(response).to redirect_to(advocates_admin_advocates_url)
      end
    end

    context 'when invalid' do
      it 'does not create a advocate' do
        expect {
          post :create, advocate: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'xxx' }, role: 'advocate' }
        }.to_not change(User, :count)
      end

      it 'renders the new template' do
        post :create, advocate: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'xxx' }, role: 'advocate' }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT #update" do

    context 'when valid' do
      before(:each) { put :update, id: subject, advocate: { role: 'admin' } }

      it 'updates a advocate' do
        subject.reload
        expect(subject.reload.role).to eq('admin')
      end

      it 'redirects to advocates index' do
        expect(response).to redirect_to(advocates_admin_advocates_url)
      end
    end

    context 'when invalid' do
      before(:each) { put :update, id: subject, advocate: { role: 'foo' } }

      it 'does not update advocate' do
        subject.reload
        expect(subject.role).to eq('advocate')
        expect(subject.email).to_not eq('emailexample.com')
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "PUT #update_password" do

    before do
      subject.user.update(password: 'password', password_confirmation: 'password')
      sign_in subject.user #need to sign in again after password change
    end

    context 'when valid' do
      before(:each) do
        put :update_password, id: subject, advocate: { user_attributes: { current_password: 'password', password: 'password123', password_confirmation: 'password123' } }
      end

      it 'redirects to advocate show action' do
        # put :update_password, id: advocate, advocate: { user_attributes: { current_password: 'password', password: 'password123', password_confirmation: 'password123' } }
        expect(response).to redirect_to(advocates_admin_advocate_path(subject))
      end
    end

    context 'when invalid' do
      before(:each) { put :update_password, id: subject, advocate: { user_attributes: { } } }

      it 'renders the change password template' do
        expect(response).to render_template(:change_password)
      end
    end
  end

  describe "DELETE #destroy" do

    before { delete :destroy, id: subject }

    it 'destroys the advocate' do
      expect(Advocate.count).to eq(1)
    end

    it 'redirects to advocate admin root url' do
      expect(response).to redirect_to(advocates_admin_advocates_url)
    end
  end
end
