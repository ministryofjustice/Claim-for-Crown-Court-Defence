# frozen_string_literal: true

RSpec.describe ErrorMessage::DetailFactory do
  subject(:factory) { described_class.new(sequencer: sequencer) }

  let(:sequencer) { instance_double(ErrorMessage::Sequencer) }

  before { allow(sequencer).to receive(:generate).with('attribute').and_return(123) }

  describe '#build' do
    subject(:detail) { factory.build(key, message) }

    let(:key) { 'attribute' }
    let(:message) do
      instance_double(
        ErrorMessage::Message,
        long: 'Long message',
        short: 'Short message',
        api: 'API message'
      )
    end

    it { is_expected.to be_an_instance_of(ErrorMessage::Detail) }
    it { expect(detail.sequence).to eq(123) }
  end
end
