require 'rails_helper'

RSpec.describe SuperAdmins::ChambersController, type: :controller do

  let(:super_admin) { create(:super_admin) }
  let(:params)      { {name: 'St Johns', supplier_number: '4321'} }
  let(:chambers)    { create_list(:chamber, 5) }
  let(:chamber)     { create(:chamber) }

  subject { chamber }

  before { sign_in super_admin.user }

  describe "GET #show" do
    before { get :show, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @chamber' do
      expect(assigns(:chamber)).to eql(subject)
    end
  end

  describe "GET #index" do
    before { get :index }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @chambers to ALL chambers' do
      chambers.each do |chamber|
        expect(assigns(:chambers)).to include(chamber)
      end
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

    it "creates a new chamber" do
      expect(flash[:notice]).to eq 'Chamber successfully created'
    end

    it 'redirects to index' do
      expect(response).to redirect_to(super_admins_root_path)
    end

  end

end
