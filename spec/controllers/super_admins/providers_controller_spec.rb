require 'rails_helper'

RSpec.describe SuperAdmins::ProvidersController, type: :controller do
  let(:super_admin) { create(:super_admin) }
  let(:providers)    { create_list(:provider, 5) }
  let(:provider)     { create(:provider) }

  subject { provider }

  before { sign_in super_admin.user }

  describe "GET #show" do
    before { get :show, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eql(subject)
    end
  end

  describe "GET #index" do
    before { get :index }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @providers to ALL providers' do
      providers.each do |provider|
        expect(assigns(:providers)).to include(provider)
      end
    end

  end

  describe "GET #edit" do
    before { get :edit, id: subject}

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eql(subject)
    end

  end

  describe "PUT #update" do
    before { subject.update(supplier_number: 'AB123') }

    it 'does not allow updating of provider type' do
      provider = create(:provider, :firm)
      put :update, id: provider, provider: { provider_type: 'chamber' }
      expect(provider).to be_firm
    end

    context 'when valid' do
      before(:each) { put :update, id: subject, provider: { supplier_number: 'XY123' } }

      it 'updates successfully' do
        subject.reload
        expect(subject.reload.supplier_number).to eq('XY123')
      end

      it 'redirects to providers show page' do
        expect(response).to redirect_to(super_admins_provider_path(subject))
      end
    end

    context 'when invalid' do
      before(:each) { put :update, id: subject, provider: { name: '' } }

      it 'does not update provider' do
        subject.reload
        expect(subject.supplier_number).to eq('AB123')
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "GET #new" do
    before { get :new }

    it 'returns http succes' do
      expect(response).to have_http_status(:success)
    end

    it "assigns a new provider to @provider" do
      expect(assigns(:provider)).to be_a_new(Provider)
    end
  end

  describe "POST #create" do
    before(:each) do
      post :create, provider: params
    end

    context 'when valid' do
      let(:params) do
        { provider_type: 'firm', name: 'St Johns', supplier_number: '4321' }
      end

      it "creates a new provider" do
        expect(flash[:notice]).to eq 'Provider successfully created'
      end

      it 'redirects to index' do
        expect(response).to redirect_to(super_admins_root_path)
      end
    end

    context 'when invalid' do
      let(:params) do
        { name: 'St Johns', supplier_number: '4321' }
      end

      it "does not create a provider" do
        expect(Provider.count).to eq(0)
      end

      it 'renders new action' do
        expect(response).to render_template(:new)
      end
    end
  end
end
