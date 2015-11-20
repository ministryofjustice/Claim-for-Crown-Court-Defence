require 'rails_helper'
require 'json'

RSpec.describe SuperAdmins::AdvocatesController, type: :controller do

  let(:super_admin) { create(:super_admin) }
  let(:chamber)     { create(:chamber) }

  let(:frozen_time)  { 6.months.ago }
  let(:advocate)   do
    Timecop.freeze(frozen_time) { create(:advocate, :admin, chamber: chamber) }
  end

  # subject { create(:advocate, chamber: chamber) }
  # subject { super_admin }

  before { sign_in super_admin.user }


  describe "GET #show" do
    before { get :show, chamber_id: chamber, id: advocate }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @chamber and @advocate' do
      expect(assigns(:chamber)).to eq(chamber)
      expect(assigns(:advocate)).to eq(advocate)
    end

  end

  describe "GET #index" do
    before { get :index, chamber_id: chamber }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @chamber' do
      expect(assigns(:chamber)).to eq(chamber)
    end

    it 'assigns @advocates' do
      expect(assigns(:advocates)).to include(advocate)
    end

  end

  describe "GET #new" do
    let(:advocate) do
     a = Advocate.new(chamber: chamber)
     a.build_user
     a
    end

    before { get :new, chamber_id: chamber }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    # NOTE: use json comparison because we are not interested in
    #       whether the object is the same just that it creates a
    #       new one and builds its user
    it 'assigns @chamber and @advocate' do
      expect(assigns(:chamber)).to eq(chamber)
      expect(assigns(:advocate).to_json).to eq(advocate.to_json)
    end

    it 'builds user for @advocate' do
      expect(assigns(:advocate).user.to_json).to eq(advocate.user.to_json)
    end

    it 'renders the new template' do
      expect(response).to render_template(:new)
    end

  end

  describe "POST #create" do

    def post_to_create_advocate_action(options={})
      post :create,
            chamber_id: chamber,
            advocate: { user_attributes: {  email: 'foo@foobar.com',
                                            first_name: options[:valid]==false ? '' : 'john',
                                            last_name: 'Smith' },
                        role: 'advocate',
                        supplier_number: 'AB124' }
    end

    context 'when valid' do
      it 'creates an advocate' do
        expect{ post_to_create_advocate_action }.to change(User, :count).by(1)
      end

      it 'redirects to advocates show view' do
        post_to_create_advocate_action
        expect(response).to redirect_to(super_admins_chamber_advocate_path(chamber, Advocate.last))
      end
    end

    context 'when invalid' do
      it 'does not create an advocate' do
        expect{ post_to_create_advocate_action(valid: false) }.to_not change(User, :count)
      end

      it 'renders the new template' do
        post_to_create_advocate_action(valid: false)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #edit" do
    before { get :edit, chamber_id: chamber, id: advocate }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

   it 'assigns @chamber and @advocate' do
      expect(assigns(:chamber)).to eq(chamber)
      expect(assigns(:advocate)).to eq(advocate)
    end

    it 'renders the template' do
      expect(response).to render_template(:edit)
    end
  end

  describe "PUT #update" do

    context 'when valid' do
      before(:each) { put :update, chamber_id: chamber, id: advocate, advocate: { role: 'advocate' } }

      it 'updates a advocate' do
        advocate.reload
        expect(advocate.reload.role).to eq('advocate')
      end

      it 'redirects to advocates index' do
        expect(response).to redirect_to(super_admins_chamber_advocate_path(chamber, advocate))
      end
    end

    context 'when invalid' do
      before(:each) { put :update, chamber_id: chamber, id: advocate, advocate: { role: 'foo' } }

      it 'does not update advocate' do
        advocate.reload
        expect(advocate.role).to eq('admin')
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "GET #change_password" do
    before { get :change_password, chamber_id: chamber, id: advocate }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @chamber and @advocate' do
      expect(assigns(:advocate)).to eq(advocate)
      expect(assigns(:chamber)).to eq(chamber)
    end

    it 'renders the change password template' do
      expect(response).to render_template(:change_password)
    end
  end

  describe "PUT #update_password" do

    context 'when valid' do

      before(:each) do
        put :update_password, chamber_id: chamber, id: advocate, advocate: { user_attributes: { password: 'password123', password_confirmation: 'password123' } }
        advocate.reload
      end

      it 'does not require current password to be successful in updating the user record ' do
        expect(advocate.user.updated_at).to_not eql frozen_time
      end

      it 'redirects to advocate show action' do
        expect(response).to redirect_to(super_admins_chamber_advocate_path(chamber,advocate))
      end
    end

    context 'when invalid' do

      before(:each) do
        put :update_password, chamber_id: chamber, id: advocate, advocate: { user_attributes: { password: 'password123', password_confirmation: 'passwordxxx' } }
      end

      it 'does not update the user record' do
        expect(advocate.user.updated_at).to eql frozen_time
      end

      it 'renders the change password template' do
        expect(response).to render_template(:change_password)
      end
    end

  end

end
