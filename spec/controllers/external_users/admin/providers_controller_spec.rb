require 'rails_helper'

RSpec.describe ExternalUsers::Admin::ProvidersController, type: :controller do
  let(:admin)     { create(:external_user, :admin, provider: provider) }
  let(:provider)  { create(:provider, :lgfs, name: 'test 123') }

  subject { provider }

  before { sign_in admin.user }

  describe "GET #show" do
    before { get :show, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @provider' do
      expect(assigns(:provider)).to eql(subject)
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
    it 'does not allow updating of provider type' do
      put :update, id: subject, provider: {provider_type: 'chamber'}
      expect(subject.reload).to be_firm
    end

    context 'when valid' do
      before(:each) { put :update, id: subject, provider: {name: 'test firm'} }

      it 'updates successfully' do
        expect(subject.reload.name).to eq('test firm')
      end

      it 'redirects to providers show page' do
        expect(response).to redirect_to(external_users_admin_provider_path(subject))
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

      before(:each) { subject.supplier_numbers.delete_all }

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
          subject.reload
          expect(subject.supplier_numbers).to be_empty
        end

        it 'renders the edit template' do
          expect(response).to render_template(:edit)
        end
      end

      context 'when valid' do
        before(:each) do
          put :update, id: subject, provider: {
              supplier_numbers_attributes: [
                  {supplier_number: '1B222Z'},
                  {supplier_number: '2B555Z'}
              ]
          }
        end

        it 'updates the provider' do
          subject.reload
          expect(subject.supplier_numbers.map(&:supplier_number).sort).to eq(%w(1B222Z 2B555Z))
        end

        it 'redirects to providers show page' do
          expect(response).to redirect_to(external_users_admin_provider_path(subject))
        end
      end
    end
  end
end
