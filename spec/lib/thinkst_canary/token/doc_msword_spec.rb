require 'rails_helper'

RSpec.shared_examples 'a Canary token' do |type, extra_options|
  describe '.new' do
    subject(:token) { described_class.new(**token_options) }

    let(:canary_token) { 'canary_token' }
    let(:token_options) do
      {
        memo: 'An test Canary token',
        factory_auth: 'factory_auth',
        flock_id: 'flock_id'
      }.merge(extra_options.to_h)
    end

    before do
      allow(ThinkstCanary.configuration).to receive(:post_query)
        .and_return({ 'canarytoken' => { 'canarytoken' => canary_token } })

      token
    end

    context 'when creating a new token' do
      it do
        expect(ThinkstCanary.configuration)
          .to have_received(:post_query)
          .with('/api/v1/canarytoken/factory/create', auth: false, params: token_options.merge(type: type))
      end

      it { expect(token.canary_token).to eq(canary_token) }
    end

    context 'when using an existing Canary token' do
      let(:existing_canary_token) { 'existing_canary_token' }
      let(:token_options) { super().merge(canary_token: existing_canary_token) }

      it { expect(ThinkstCanary.configuration).not_to have_received(:post_query) }
      it { expect(token.canary_token).to eq(existing_canary_token) }
    end
  end
end

RSpec.describe ThinkstCanary::Token::DocMsword do
  it_behaves_like 'a Canary token',
                  'doc-msword',
                  { doc: 'file.docx; type=application/vnd.openxmlformats-officedocument.wordprocessingml.document' }
end
