require 'rails_helper'

RSpec.describe DualLogin, :aggregate_failures do
  before do
    allow(Settings).to receive_messages(feature_flags_enabled?: true, active_features: [], dual_login_enabled?: false)
  end

  it 'defaults to restricted pilot mode' do
    expect(described_class).not_to be_public_rollout
    expect(described_class.eligible?(create(:user))).to be false
    expect(described_class.eligible?(nil)).to be false
  end

  it 'allows only approved accounts with an existing route in pilot mode' do
    user = create(:user)
    user.login_route.update!(dual_login_tester: true)
    expect(described_class.eligible?(user)).to be true
    user.login_route.destroy!
    expect(described_class.eligible?(user.reload)).to be false
  end

  it 'allows everyone in public rollout mode while preserving other features' do
    allow(Settings).to receive_messages(dual_login_enabled?: true, active_features: ['another_feature'])
    expect(described_class).to be_public_rollout
    expect(described_class.eligible?(nil)).to be true
    expect(FeatureFlag.active?(:another_feature)).to be true
  end

  it 'honours the master switch even when rollout is configured' do
    allow(Settings).to receive_messages(feature_flags_enabled?: false, dual_login_enabled?: true)
    expect(described_class).not_to be_public_rollout
    expect(described_class.eligible?(nil)).to be false
  end

  it 'handles symbol and string feature names' do
    allow(Settings).to receive(:active_features).and_return([:dual_login, 'another_feature'])
    expect(described_class).to be_public_rollout
    expect(FeatureFlag.active?(:another_feature)).to be true
  end

  [nil, 'false', 'true'].each do |value|
    it "loads DUAL_LOGIN_ENABLED=#{value.inspect} as a boolean" do
      Dotenv.modify('DUAL_LOGIN_ENABLED' => value) do
        settings = YAML.safe_load(ERB.new(Rails.root.join('config', 'settings.yml').read).result,
                                  permitted_classes: [Symbol, Date, Time, Regexp], aliases: true)
        expect(settings['dual_login_enabled?']).to eq(value == 'true')
      end
    end
  end
end
