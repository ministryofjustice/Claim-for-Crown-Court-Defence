require 'rails_helper'

RSpec.describe 'Content Security Policy reports' do
  describe 'POST /csp_report' do
    let(:params) do
      {
        'csp-report': {
          'document-uri': 'https://example.com',
          referrer: '',
          'violated-directive': 'connect-src',
          'effective-directive': 'connect-src',
          'original-policy': "default-src 'self' https:; script-src 'self' https: 'nonce-123'",
          disposition: 'report',
          'blocked-uri': 'ws://example.com:35729/livereload',
          'line-number': 191,
          'column-number': 27,
          'source-file': 'http://example:com/__rack/livereload.js',
          'status-code': 200,
          'script-sample': ''
        }
      }.to_json
    end

    before do
      stub_request(:post, 'https://slack').and_return(status: 200)
      allow(Settings).to receive(:slack).and_return(Struct.new(:bot_url).new('https://slack'))

      post csp_report_url, params:
    end

    it { expect(response).to be_successful }

    context 'with an empty body' do
      let(:params) { '' }

      it { expect(response).to be_successful }
    end
  end
end
