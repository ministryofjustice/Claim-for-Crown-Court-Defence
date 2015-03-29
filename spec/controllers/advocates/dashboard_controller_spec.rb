require 'rails_helper'

RSpec.describe Advocates::DashboardController, type: :controller do
  let(:advocate) { create(:advocate) }
  let(:case_worker) { create(:case_worker) }

  describe 'GET #index' do
    context 'when signed in as an advocate' do
      before do
        sign_in advocate
        get :index
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the index template' do
        expect(response).to render_template(:index)
      end
    end

    context 'when signed in as a case worker' do
      before do
        sign_in case_worker
        get :index
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to(root_url)
      end

      it 'puts an alert in the flash' do
        expect(flash[:alert]).to match(/must be signed in as an advocate/i)
      end
    end

    context 'when not signed in' do
      before do
        get :index
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to(root_url)
      end

      it 'puts an alert in the flash' do
        expect(flash[:alert]).to match(/must be signed in as an advocate/i)
      end
    end
  end
end
