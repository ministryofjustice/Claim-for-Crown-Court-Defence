require 'rails_helper'

RSpec.describe ThinkstCanary::FactoryGenerator do
  subject(:generator) { described_class.new }

  describe '#create_factory' do
    subject(:create_factory) { generator.create_factory(**factory_options) }

    let(:factory_options) { { flock_id: 'test_flock', memo: 'test_memo' } }
    let(:factory_response) { { 'factory_auth' => 'factory_auth_token', 'result' => 'success' } }

    before do
      allow(ThinkstCanary.configuration).to receive(:query).and_return(factory_response)
    end

    it { is_expected.to be_a ThinkstCanary::Factory }
    it { expect(create_factory.factory_auth).to eq(factory_response['factory_auth']) }
    it { expect(create_factory.flock_id).to eq(factory_options[:flock_id]) }
    it { expect(create_factory.memo).to eq(factory_options[:memo]) }

    it 'makes a POST request for a factory' do
      create_factory

      expect(ThinkstCanary.configuration).to have_received(:query).with(
        :post, '/api/v1/canarytoken/create_factory',
        params: { flock_id: factory_options[:flock_id], memo: factory_options[:memo] }
      )
    end
  end
end
