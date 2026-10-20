# frozen_string_literal: true

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
end
