require 'rails_helper'
require 'google_analytics/api'

describe GoogleAnalytics::API do
  subject(:api) { described_class }

  let(:endpoint) { 'http://example.com' }
  let(:tracker_id) { 'GA123456' }
  let(:version) { '1' }
  let(:fallback_client_id) { '555' }

  before do
    allow(Settings.google_analytics).to receive_messages(
      endpoint:,
      tracker_id:,
      version:,
      fallback_client_id:
    )
  end

  describe '.event' do
    subject(:api_event) { api.event(category, event, label) }

    let(:event) { '5' }
    let(:category) { 'satisfaction' }
    let(:label) { nil }

    it 'submits a get request via RestClient' do
      params = { v: '1', tid: 'GA123456', cid: '555', t: 'event', ec: 'satisfaction', ea: '5' }
      expect(RestClient).to receive(:get).with('http://example.com', params:, timeout: 4, open_timeout: 4)
      subject
    end

    describe 'when tracker_id is not set' do
      let(:tracker_id) { nil }

      it { is_expected.to be_nil }
    end

    describe 'and label' do
      describe 'is included' do
        let(:label) { 'satisfaction-satisfied' }

        it 'is added to the params' do
          params = { v: '1', tid: 'GA123456', cid: '555', t: 'event', ec: 'satisfaction', ea: '5', el: label }
          expect(RestClient).to receive(:get).with('http://example.com', params:, timeout: 4, open_timeout: 4)
          subject
        end
      end
    end
  end

  describe '.endpoint' do
    subject(:api_endpoint) { api.endpoint }

    describe 'when set' do
      it { is_expected.to eq endpoint }
    end

    describe 'when not set' do
      let(:endpoint) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe '.tracker_id' do
    subject(:api_tracker_id) { api.tracker_id }

    describe 'when set' do
      it { is_expected.to eq tracker_id }
    end

    describe 'when not set' do
      let(:tracker_id) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe '.version' do
    subject(:api_version) { api.version }

    describe 'when set' do
      it { is_expected.to eq version }
    end

    describe 'when not set' do
      let(:version) { nil }

      it { is_expected.to be_nil }
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
