require 'rails_helper'

RSpec.describe SuperAdmins::ProvidersController, type: :controller do
  let(:super_admin) { create(:super_admin) }
  let(:providers)   { create_list(:provider, 5) }
  let(:provider)    { create(:provider, :lgfs, name: 'test 123') }

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
    before { get :edit, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eql(subject)
    end
  end

  describe "PUT #update" do

    context 'when valid' do
      before(:each) { put :update, id: subject, provider: {name: 'test firm'} }

      it 'updates successfully' do
        expect(subject.reload.name).to eq('test firm')
      end

      it 'redirects to providers show page' do
        expect(response).to redirect_to(super_admins_provider_path(subject))
      end
    end

    context 'when invalid' do
      before(:each) { put :update, id: subject, provider: {name: ''} }

      it 'does not update provider' do
        expect(subject.reload.name).to eq('test 123')
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end

    describe 'multiple supplier numbers' do
      let(:provider) { create(:provider, :lgfs) }
      subject { provider }

      before(:each) { subject.lgfs_supplier_numbers.delete_all }

      context 'when invalid' do
        before(:each) do
          put :update, id: subject, provider: {
              supplier_numbers_attributes: [
                  {supplier_number: 'XY123'},
                  {supplier_number: ''}
              ]
          }
        end

        it 'does not update provider' do
          expect(subject.reload.lgfs_supplier_numbers).to be_empty
        end

        it 'renders the edit template' do
          expect(response).to render_template(:edit)
        end
      end

      context 'when valid' do
        before(:each) do
          put :update, id: subject, provider: {
              lgfs_supplier_numbers_attributes: [
                  {supplier_number: '1B222Z'},
                  {supplier_number: '2B555Z'}
              ]
          }
        end

        it 'updates the provider' do
          expect(subject.reload.lgfs_supplier_numbers.map(&:supplier_number).sort).to eq(%w(1B222Z 2B555Z))
        end

        it 'redirects to providers show page' do
          expect(response).to redirect_to(super_admins_provider_path(subject))
        end
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
        {
          provider_type: 'firm',
          name: 'St Johns',
          firm_agfs_supplier_number: '2M462',
          roles: ['lgfs', 'agfs'],
          lgfs_supplier_numbers_attributes: {
            '0'=>{'supplier_number' => '2E481W', '_destroy' => 'false'}
          }
        }
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
        {name: 'St Johns', supplier_number: '4321'}
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
