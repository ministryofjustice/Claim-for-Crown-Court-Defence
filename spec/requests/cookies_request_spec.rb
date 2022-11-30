require 'rails_helper'

RSpec.describe 'Cookies' do
  describe 'GET /help/cookies' do
    before { get '/help/cookies' }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @cookies' do
      expect(assigns(:cookies)).to be_instance_of Cookies
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end

    it 'sets @cookies.analytics based on value of cookies' do
      expect(assigns(:cookies).analytics.to_s).to eq cookies[:usage_opt_in]
    end
  end

  describe 'POST /help/cookies' do
    context 'when cookies are valid' do
      before { post '/help/cookies', params: { cookies: { analytics: true } } }

      it 'sets the flash message' do
        expect(flash[:success]).to eq 'You’ve set your cookie preferences.'
      end

      it 'sets the usage_opt_in cookie' do
        expect(cookies[:usage_opt_in]).to eq 'true'
      end

      it 'sets the cookies_preference cookie' do
        expect(cookies[:cookies_preference]).to eq 'true'
      end

      it 'assigns the value of @cookies_preferences_set' do
        expect(assigns(:cookies_preferences_set)).to be true
      end

      it 'redirects to cookies path' do
        expect(response).to redirect_to cookies_path
      end
    end

    context 'when cookies are invalid' do
      before { post '/help/cookies', params: { cookies: { analytics: nil } } }

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end

      it 'sets an error message' do
        expect(assigns(:cookies).errors[:analytics]).to include 'Choose analytics cookie setting'
      end
    end
  end

  describe 'GET /help/cookie-details' do
    it 'returns http success' do
      get '/help/cookie-details'
      expect(response).to have_http_status(:success)
    end
  end
end
