require 'rails_helper'

RSpec.describe SuperAdmins::ChambersController, type: :controller do

  let(:super_admin) { create(:super_admin) }
  let(:params)      { {name: 'St Johns', supplier_number: '4321'} }
  let(:chambers)    { FactoryGirl.create_list(:chamber, 5) }

  subject { FactoryGirl.create(:chamber) }

  before { sign_in super_admin.user }

  describe "GET #show" do
    before { get :show, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @chamber' do
      expect(assigns(:chamber)).to subject
    end
  end

  describe "GET #index" do
    before { get :index }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @chambers' do
      expect(assigns(:chambers)).to chambers
    end

  end

  describe "GET #new" do
    before { get :new }

    it 'returns http succes' do
      expect(response).to have_http_status(:success)
    end

    it "assigns a new chamber to @chamber" do
      expect(assigns(:chamber)).to be_a_new(Chamber)
    end
  end

  describe "POST #create" do
    before(:each) do
      post :create, chamber: params
    end

    it "creates a new chmaber" do
      expect(flash[:success]).to eq 'Chamber created'
    end

    it 'redirects to index' do
      expect(response).to redirect_to(super_admins_root_path)
    end

  end

end
