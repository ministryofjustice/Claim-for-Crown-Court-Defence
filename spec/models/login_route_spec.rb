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

  it 'rejects unknown login methods' do
    expect(build(:login_route, login_method: 'magic')).not_to be_valid
  end

  it 'requires a user' do
    expect(described_class.new(login_method: LoginRoute::LEGACY)).not_to be_valid
  end

  it 'shares its primary key with the user' do
    user = create(:user)
    expect(user.login_route.id).to eq user.id
  end

  it 'is destroyed with the user' do
    route = create(:user).login_route
    expect { route.user.destroy }.to change(described_class, :count).by(-1)
  end

  describe '.method_for' do
    it 'returns the mapped method regardless of case or whitespace' do
      user = create(:user, email: 'a@example.com')
      user.login_route.update!(login_method: LoginRoute::ENTRA)
      expect(described_class.method_for(' A@Example.com ')).to eq LoginRoute::ENTRA
    end

    it 'defaults to legacy for a user without a route' do
      create(:user, email: 'unrouted@example.com')
      expect(described_class.method_for('unrouted@example.com')).to eq LoginRoute::LEGACY
    end

    it 'defaults to legacy for an unknown email' do
      expect(described_class.method_for('unknown@example.com')).to eq LoginRoute::LEGACY
    end

    it 'defaults to legacy for a blank email' do
      expect(described_class.method_for(nil)).to eq LoginRoute::LEGACY
    end
  end
end
