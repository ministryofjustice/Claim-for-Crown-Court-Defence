require 'rails_helper'

RSpec.describe JsonTemplateController, type: :controller do
  describe 'GET #index' do
    it 'yields a successful response' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns @schema' do
      get :index
      expect(assigns(:schema).blank?).to be false
    end

    it 'renders the template' do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
