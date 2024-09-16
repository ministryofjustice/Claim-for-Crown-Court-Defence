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
          'source-file': source_file,
          'status-code': 200,
          'script-sample': ''
        }
      }.to_json
    end

    let(:source_file) { 'http://example:com/__rack/livereload.js' }

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

    context 'when the violation is caused by a chrome extension' do
      let(:source_file) { 'chrome-extension' }

      it { expect(response).to be_successful }
      it { expect(a_request(:post, 'https://slack')).not_to have_been_made }
    end
  end
end
