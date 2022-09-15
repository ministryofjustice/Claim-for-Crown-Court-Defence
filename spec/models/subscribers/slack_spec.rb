require 'rails_helper'

RSpec.describe Subscribers::Slack, type: :subscriber do
  describe '#process' do
    subject(:process) { described_class.new(event_name, start, ending, transaction_id, payload) }

    let(:event_name) { 'call_failed.stats_report' }
    let(:start) { 2.minutes.ago }
    let(:ending) { 1.minute.ago }
    let(:transaction_id) { SecureRandom.uuid }
    let(:error) { StandardError.new('Test error') }
    let(:payload) { { id: 999, name: 'provisional_assessment', error: } }
    let(:notifier) { instance_double(SlackNotifier) }
    let(:send_result) { double(:send_result) }

    before do
      allow(SlackNotifier).to receive(:new).and_return(notifier)
      allow(notifier).to receive(:build_payload)
      allow(notifier).to receive(:send_message).and_return(send_result)

      process
    end

    it { is_expected.to be_a(Subscribers::Base) }

    it 'creates a new SlackNotifier' do
      expect(SlackNotifier)
        .to have_received(:new)
        .with('laa-cccd-alerts', formatter: an_instance_of(SlackNotifier::Formatter::Generic))
    end

    it 'builds the payload with the notifier arguments' do
      notifier_args = {
        icon: ':robot_face:',
        title: 'provisional_assessment failed on test',
        message: "Error: Test error\nStats::StatsReport.id: 999",
        status: :fail
      }

      expect(notifier).to have_received(:build_payload).with(**notifier_args)
    end

    it 'sends the message with the notifier' do
      expect(notifier).to have_received(:send_message)
    end
  end
end
