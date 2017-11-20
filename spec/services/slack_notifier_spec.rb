require 'rails_helper'

RSpec.describe SlackNotifier, slack_bot: true do
  subject(:slack_notifier) { described_class.new() }

  it { is_expected.to be_a described_class }

  it { is_expected.to respond_to :build_injection }
  it { is_expected.to respond_to :send_message! }

  describe '#send_message!' do
    subject(:send_message!) { slack_notifier.send_message! }

    context 'before message payload is set' do
      it 'raises an error' do
        expect{ subject }.to raise_error(RuntimeError, 'Unable to send without payload')
      end
    end

    context 'after payload set' do
      before { slack_notifier.build_injection }
      it 'calls the slack api' do
        subject
        expect(a_request(:post, "https://hooks.slack.com/services/fake/endpoint")).to have_been_made.times(1)
      end
    end
  end
end
