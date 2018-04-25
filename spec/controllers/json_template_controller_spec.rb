require 'rails_helper'

RSpec.describe JsonTemplateController, type: :controller do

  describe 'GET #index' do
    before do
      get :index
    end

    it 'yields a successful response' do
      expect(response).to be_success
    end

    it 'assigns @schema' do
      expect(assigns(:schema)).to be_present
    end

    it 'renders the template' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show/:schema' do
    before do
      get :show, params: { schema: 'ccr_schema' }
    end

    it 'yields a successful response' do
      expect(response).to be_success
    end

    it 'assigns @schema' do
      expect(assigns(:schema)).to be_present
    end

    it 'renders json' do
      expect(response.content_type).to eq "application/json"
    end
  end
end
