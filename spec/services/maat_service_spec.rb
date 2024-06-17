RSpec.describe MaatService do
  before do
    allow(OAuth2::Client).to receive(:new).and_return(
      OAuth2::Client.new(
        Settings.maat_api_oauth_client_id,
        Settings.maat_api_oauth_client_secret,
        site: 'https://example.com',
        token_url: 'https://example.com/oauth'
      )
    )
    stub_request(:post, 'https://example.com/oauth').to_return(
      body: {
        access_token: 'test-token',
        expires_in: 3600,
        token_type: 'Bearer'
      }.to_json,
      headers: { 'content-type': 'application/json' }
    )
  end

  describe '.call' do
    subject { described_class.call(maat_reference:) }

    let(:maat_reference) { '9876543' }
    let(:connection) { MaatService::Connection.instance }

    context 'with a valid MAAT reference' do
      before do
        stub_request(:get, "https://example.com/assessment/rep-orders/#{maat_reference}")
          .to_return(
            body: {
              caseId: 'TEST12345678',
              crownRepOrderDate: '2024-03-28',
              arrestSummonsNo: 'ABCDEF'
            }.to_json
          )
      end

      it { is_expected.to eq({ case_number: 'TEST12345678', representation_order_date: '2024-03-28', asn: 'ABCDEF' }) }
    end

    context 'with a valid MAAT reference with no date' do
      before do
        stub_request(:get, "https://example.com/assessment/rep-orders/#{maat_reference}")
          .to_return(body: { caseId: 'TEST12345678' }.to_json)
      end

      it { is_expected.to eq({ case_number: 'TEST12345678', representation_order_date: nil, asn: nil }) }
    end

    context 'with an unknown MAAT reference' do
      before do
        stub_request(:get, "https://example.com/assessment/rep-orders/#{maat_reference}")
          .to_return(status: 404, body: { message: "No Rep Order found for ID: #{maat_reference}" }.to_json)
      end

      it { is_expected.to eq({ case_number: nil, representation_order_date: nil, asn: nil }) }
    end

    context 'when unauthorized' do
      before do
        stub_request(:get, "https://example.com/assessment/rep-orders/#{maat_reference}")
          .to_return(status: 401, body: { message: 'Unauthorized' }.to_json)
      end

      it { is_expected.to eq({ case_number: nil, representation_order_date: nil, asn: nil }) }
    end

    context 'when the OAuth settings are not correct' do
      before do
        stub_request(:post, 'https://example.com/oauth')
          .to_return(
            status: 400,
            body: { error: 'invalid_client' }.to_json,
            headers: { 'content-type': 'application/json' }
          )
      end

      it { is_expected.to eq({ case_number: nil, representation_order_date: nil, asn: nil }) }
    end
  end
end
