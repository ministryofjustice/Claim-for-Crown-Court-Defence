# frozen_string_literal: true

describe CookiesController do
  describe 'GET #new' do
    before { get :new }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @cookies' do
      expect(assigns(:cookies)).to be_new_record
    end

    it 'sets the value of cookies' do

    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end
  end
end
