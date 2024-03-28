RSpec.describe MaatService do
  before do
    allow(Settings).to receive_messages(maat_api_url: 'https://example.com', maat_api_oauth_url: 'https://example.com/oauth')
    stub_request(:post, 'https://example.com/oauth')
      .to_return(body: { access_token: 'test_token' }.to_json)
  end

  describe '.call' do
    subject { described_class.call(maat_reference:) }

    let(:maat_reference) { '9876543' }
    let(:connection) { MaatService::Connection.instance }

    context 'with a valid MAAT reference' do
      before do
        stub_request(:get, "https://example.com/assessment/rep-orders/#{maat_reference}")
          .to_return(body: { caseId: 'TEST12345678', crownRepOrderDate: '2024-03-28' }.to_json)
      end

      it { is_expected.to eq({ case_number: 'TEST12345678', representation_order_date: '2024-03-28' }) }
    end

    context 'with a valid MAAT reference with no date' do
      before do
        stub_request(:get, "https://example.com/assessment/rep-orders/#{maat_reference}")
          .to_return(body: { caseId: 'TEST12345678' }.to_json)
      end

      it { is_expected.to eq({ case_number: 'TEST12345678', representation_order_date: nil }) }
    end

    context 'with an unknown MAAT reference' do
      before do
        stub_request(:get, "https://example.com/assessment/rep-orders/#{maat_reference}")
          .to_return(status: 404, body: { message: "No Rep Order found for ID: #{maat_reference}" }.to_json)
      end

      it { is_expected.to eq({ case_number: nil, representation_order_date: nil }) }
    end

    context 'when unauthorized' do
      before do
        stub_request(:get, "https://example.com/assessment/rep-orders/#{maat_reference}")
          .to_return(status: 401, body: { message: 'Unauthorized' }.to_json)
      end

      it { is_expected.to eq({ case_number: nil, representation_order_date: nil }) }
    end

    context 'when the OAuth settings are not correct' do
      before do
        stub_request(:post, 'https://example.com/oauth')
          .to_return(status: 400, body: { error: 'invalid_client' }.to_json)
        stub_request(:get, "https://example.com/assessment/rep-orders/#{maat_reference}")
          .to_return(status: 401, body: { message: 'Unauthorized' }.to_json)
      end

      it { is_expected.to eq({ case_number: nil, representation_order_date: nil }) }
    end
  end
end
