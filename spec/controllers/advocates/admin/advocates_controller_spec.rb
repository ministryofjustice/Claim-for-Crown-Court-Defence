require 'rails_helper'

RSpec.describe Advocates::Admin::AdvocatesController, type: :controller do
  let(:admin) { create(:advocate, :admin) }

  before { sign_in admin.user }

  describe "GET #index" do
    before { get :index }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @advocates' do
      advocate = create(:advocate, chamber: admin.chamber)
      other_chamber_advocate = create(:advocate)
      expect(assigns(:advocates)).to match_array([admin, advocate])
    end

    it 'renders the template' do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    subject { create(:advocate) }

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
    subject { create(:advocate) }

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

  describe "POST #create" do
    context 'when valid' do
      it 'creates a advocate' do
        expect {
          post :create, advocate: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'password', first_name: 'John', last_name: 'Smith' },
                                    role: 'advocate',
                                    account_number: 'AB124' }
        }.to change(User, :count).by(1)
      end

      it 'redirects to advocates index' do
        post :create, advocate: { user_attributes: { email: 'foo@foobar.com', password: 'password', password_confirmation: 'password', first_name: 'John', last_name: 'Smith'},
                                  role: 'advocate',
                                  account_number: 'XY123'  }
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
    subject { create(:advocate) }

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

  describe "DELETE #destroy" do
    subject { create(:advocate) }

    before { delete :destroy, id: subject }

    it 'destroys the advocate' do
      expect(Advocate.count).to eq(1)
    end

    it 'redirects to advocate admin root url' do
      expect(response).to redirect_to(advocates_admin_advocates_url)
    end
  end
end
