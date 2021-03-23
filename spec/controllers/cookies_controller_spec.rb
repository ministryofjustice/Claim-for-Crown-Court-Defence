# frozen_string_literal: true

describe CookiesController do
  describe 'GET #new' do
    before do
      cookies[:usage_opt_in] = true
      get :new
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'sets the value of the analytics cookies' do
      expect(assigns(:cookies).analytics).to eq 'true'
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let(:cookie) { instance_double Cookies, analytics: true }

    before do
      allow(Cookies).to receive(:new) { cookie }
    end

    context 'when cookies are valid' do
      before do
        allow(cookie).to receive(:valid?).and_return(true)
        post :create, params: { cookies: { analytics: true } }
      end

      it 'sets the flash message' do
        expect(flash[:success]).to eq I18n.t('cookies.new.cookie_notification')
      end

      it 'sets the usage_opt_in cookie' do
        expect(cookies[:usage_opt_in]).to eq true
      end

      it 'sets the cookies_preference cookie' do
        expect(cookies[:cookies_preference]).to eq true
      end

      it 'assigns the value of @cookies_preferences_set' do
        expect(assigns(:cookies_preferences_set)).to eq true
      end

      it 'redirects to cookies path' do
        expect(response).to redirect_to cookies_path
      end
    end

    context 'when cookies are invalid' do
      before do
        allow(cookie).to receive(:valid?).and_return(false)
        post :create, params: { cookies: { analytics: true } }
      end

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end
    end
  end
end
