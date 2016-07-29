require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe 'PUT #update_settings' do
    let(:external_user) { create(:external_user) }
    let(:user) { external_user.user }

    before do
      sign_in user
      expect(user.settings).to eq({})
    end

    def do_put(params = {})
      put :update_settings, params.merge(id: user, format: :js)
      user.reload
    end

    it 'updates the setting' do
      do_put(api_promo_seen: 'test')
      expect(user.settings).to eq({'api_promo_seen' => 'test'})
    end
  end

end
