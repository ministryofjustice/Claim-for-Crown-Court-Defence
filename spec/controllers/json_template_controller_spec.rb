require 'rails_helper'

RSpec.describe JsonTemplateController, type: :controller do
  describe 'GET #show/:schema' do
    before do
      get :show, params: { schema: 'ccr_schema' }
    end

    it 'yields a successful response' do
      expect(response).to be_successful
    end

    it 'assigns @schema' do
      expect(assigns(:schema)).to be_present
    end

    it 'renders json' do
      expect(response.media_type).to eq 'application/json'
    end
  end
end
