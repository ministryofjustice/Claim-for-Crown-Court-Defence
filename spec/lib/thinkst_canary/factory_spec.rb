require 'rails_helper'

RSpec.shared_examples 'Thinkst Canary create token' do
  let(:token) { instance_double(klass) }

  before { allow(klass).to receive(:new).and_return(token) }

  it { is_expected.to eq(token) }

  it do
    create_token

    expect(klass)
      .to have_received(:new)
      .with(token_options.except(:kind).merge(factory_options.slice(:factory_auth, :flock_id)))
  end
end

RSpec.describe ThinkstCanary::Factory do
  subject(:factory) { described_class.new(**factory_options) }

  let(:factory_options) do
    {
      factory_auth: 'factory_auth',
      flock_id: 'flock_id',
      memo: 'Test factory'
    }
  end

  describe '#create_token' do
    subject(:create_token) { factory.create_token(**token_options) }

    let(:token_options) { { memo: 'Another example Canary token', kind: 'http' } }
    let(:create_params) { token_options.merge(factory_options.slice(:flock_id, :factory_auth)) }

    context 'with an unknown token kind' do
      let(:token_options) { { memo: 'An token of unknown kind', kind: 'unknown' } }
      let(:token) { instance_double(ThinkstCanary::Token::NullToken) }

      before { allow(ThinkstCanary::Token::NullToken).to receive(:new).and_return(token) }

      it { is_expected.to eq(token) }

      it do
        create_token

        expect(ThinkstCanary::Token::NullToken).to have_received(:new).with(token_options)
      end
    end

    context 'with a doc-msword token kind' do
      it_behaves_like 'Thinkst Canary create token' do
        let(:klass) { ThinkstCanary::Token::DocMsword }

        let(:token_options) do
          {
            memo: 'An MS doc example Canary token',
            kind: 'doc-msword',
            doc: 'file.docx; type=application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          }
        end
      end
    end
  end

  describe '#delete' do
    subject(:delete) { factory.delete }

    before do
      allow(ThinkstCanary.configuration).to receive(:query)

      delete
    end

    it do
      expect(ThinkstCanary.configuration).to have_received(:query).with(
        :delete, '/api/v1/canarytoken/delete_factory',
        params: { factory_auth: factory_options[:factory_auth] }
      )
    end
  end
end
