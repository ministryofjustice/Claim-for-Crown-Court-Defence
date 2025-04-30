require 'rails_helper'

RSpec.describe 'Beta testing' do
  let(:previous_page) { new_user_session_url }

  describe '/beta/enable' do
    before { get '/beta/enable', headers: { 'HTTP_REFERER' => previous_page } }

    it { expect(request).to redirect_to previous_page }
    it { expect(session['beta_testing']).to eq 'enabled' }
  end

  describe '/beta/disable' do
    before { get '/beta/disable', headers: { 'HTTP_REFERER' => previous_page } }

    it { expect(request).to redirect_to previous_page }
    it { expect(session['beta_testing']).to eq 'disabled' }
  end
end
