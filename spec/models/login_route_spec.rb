# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoginRoute do
  context 'with known login methods' do
    it { is_expected.to allow_value('legacy').for(:login_method) }
    it { is_expected.to allow_value('entra').for(:login_method) }
  end

  context 'with an unknown login method' do
    it { is_expected.not_to allow_value('unknown').for(:login_method) }
  end

  it 'defaults the login method to legacy' do
    expect(described_class.new.login_method).to eq('legacy')
  end

  it 'does not approve new accounts for dual-login testing by default' do
    expect(create(:user).login_route).not_to be_dual_login_tester
  end

  it 'requires a user' do
    expect(described_class.new(login_method: LoginRoute::LEGACY)).not_to be_valid
  end

  it 'is destroyed with the user' do
    route = create(:user).login_route
    expect { route.user.destroy }.to change(described_class, :count).by(-1)
  end
end
