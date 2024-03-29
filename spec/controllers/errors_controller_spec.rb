require 'rails_helper'

RSpec.describe ErrorsController do
  describe 'GET #not_endpoint' do
    before { get :not_endpoint }

    it 'has a status of 403' do
      expect(response).to have_http_status(:forbidden)
    end

    it 'renders the appropriate json' do
      json = 'Not a valid api endpoint'
      expect(response.body).to eq json
    end
  end

  describe 'GET #not_found' do
    before { get :not_found }

    it 'has a status of 404' do
      expect(response).to have_http_status(:not_found)
    end

    it 'renders the 404/not_found template' do
      expect(response).to render_template(:not_found)
    end
  end

  describe 'GET #internal_server_error' do
    before { get :internal_server_error }

    it 'has a status of 500' do
      expect(response).to have_http_status(:internal_server_error)
    end

    it 'renders the 500/internal_server_error template' do
      expect(response).to render_template(:internal_server_error)
    end
  end
end
