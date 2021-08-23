require 'rails_helper'

RSpec.describe Subscribers::Slack, type: :subscriber do
  describe '#process' do
    let(:event_name) { 'call_failed.stats_report' }
    let(:start) { 2.minutes.ago }
    let(:ending) { 1.minutes.ago }
    let(:transaction_id) { SecureRandom.uuid }
    let(:payload) { { id: 999, name: 'provisional_assessment', error: 'Some error' } }
    let(:notifier) { instance_double(SlackNotifier) }
    let(:send_result) { double(:send_result) }

    subject(:process) { described_class.new(event_name, start, ending, transaction_id, payload) }

    it 'sends a message to slack channel with the error content' do
      expect(SlackNotifier)
        .to receive(:new)
        .with('cccd_development', formatter: an_instance_of(SlackNotifier::Formatter::Generic))
        .and_return(notifier)
      notifier_args = {
        icon: ':robot_face:',
        title: 'provisional_assessment failed on test',
        message: 'Stats::StatsReport.id: 999',
        status: :fail
      }
      expect(notifier).to receive(:build_payload).with(**notifier_args)
      expect(notifier).to receive(:send_message!).and_return(send_result)
      process
      expect(process).to be_kind_of(Subscribers::Base)
    end
  end
end
