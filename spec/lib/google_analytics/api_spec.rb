require 'rails_helper'
require 'google_analytics/api'

describe GoogleAnalytics::Api do
  subject(:api) { described_class }

  let(:endpoint) { 'http://example.com' }
  let(:tracker_id) { 'GA123456' }
  let(:version) { '1' }
  let(:fallback_client_id) { '555' }

  before do
    allow(Settings.google_analytics).to receive(:endpoint).and_return(endpoint)
    allow(Settings.google_analytics).to receive(:tracker_id).and_return(tracker_id)
    allow(Settings.google_analytics).to receive(:version).and_return(version)
    allow(Settings.google_analytics).to receive(:fallback_client_id).and_return(fallback_client_id)
  end

  describe '.event' do
    subject(:api_event) { api.event(category, event) }

    let(:event) { '5' }
    let(:category) { 'satisfaction' }

    it 'submits a get request via RestClient' do
      params = { v: '1', tid: 'GA123456', cid: '555', t: 'event', ec: 'satisfaction', ea: '5' }
      expect(RestClient).to receive(:get).with('http://example.com', params: params, timeout: 4, open_timeout: 4)
      subject
    end

    describe 'when tracker_id is not set' do
      let(:tracker_id) { nil }

      it { is_expected.to be nil }
    end
  end

  describe '.endpoint' do
    subject(:api_endpoint) { api.endpoint }

    describe 'when set' do
      it { is_expected.to eq endpoint }
    end

    describe 'when not set' do
      let(:endpoint) { nil }

      it { is_expected.to be nil }
    end
  end

  describe '.tracker_id' do
    subject(:api_tracker_id) { api.tracker_id }

    describe 'when set' do
      it { is_expected.to eq tracker_id }
    end

    describe 'when not set' do
      let(:tracker_id) { nil }

      it { is_expected.to be nil }
    end
  end

  describe '.version' do
    subject(:api_version) { api.version }

    describe 'when set' do
      it { is_expected.to eq version }
    end

    describe 'when not set' do
      let(:version) { nil }

      it { is_expected.to be nil }
    end
  end

  describe '.fallback_client_id' do
    subject(:api_fallback_client_id) { api.fallback_client_id }

    describe 'when not set' do
      it { is_expected.to eq '555' }
    end

    describe 'when explicitly set' do
      let(:fallback_client_id) { '777' }

      it { is_expected.to eq '777' }
    end
  end
end
