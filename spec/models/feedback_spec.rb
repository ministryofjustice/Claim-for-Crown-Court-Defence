require 'rails_helper'

RSpec.describe Feedback do
  let(:params) do
    {
      user_agent: 'Firefox',
      referrer: '/index'
    }
  end

  it { is_expected.to validate_inclusion_of(:type).in_array(%w(feedback bug_report)) }

  context 'feedback' do
    subject(:feedback) { described_class.new(feedback_params) }

    let(:feedback_params) do
      params.merge(type: 'feedback', task: '1', rating: '4', comment: 'lorem ipsum', reason: ['', '1', '2'], other_reason: 'dolor sit')
    end

    it { expect(feedback.task).to eq '1' }
    it { expect(feedback.rating).to eq '4' }
    it { expect(feedback.comment).to eq 'lorem ipsum' }
    it { expect(feedback.reason).to eq %w[1 2] }
    it { expect(feedback.other_reason).to eq 'dolor sit' }
    it { is_expected.to be_feedback }
    it { is_expected.not_to be_bug_report }

    describe '#save' do
      subject(:save) { feedback.save }

      before { allow(SurveyMonkeySender).to receive(:call).and_return({ id: 123, success: true }) }

      context 'when Survey Monkey succeeds' do
        it 'sends the response to Survey Monkey' do
          save
          expect(SurveyMonkeySender).to have_received(:call).with(feedback)
        end
      end
    end

    describe '#is?' do
      context 'with feedback type' do
        it { expect(feedback.is?(:feedback)).to be true }
      end

      context 'with bug report type' do
        it { expect(feedback.is?(:bug_report)).to be false }
      end
    end
  end

  context 'bug report' do
    subject(:bug_report) { described_class.new(bug_report_params) }

    let(:bug_report_params) do
      params.merge(type: 'bug_report', case_number: 'XXX', event: 'lorem', outcome: 'ipsum', email: 'example@example.com')
    end

    it { expect(bug_report.email).to eq('example@example.com') }
    it { expect(bug_report.case_number).to eq('XXX') }
    it { expect(bug_report.event).to eq('lorem') }
    it { expect(bug_report.outcome).to eq('ipsum') }
    it { expect(bug_report.user_agent).to eq('Firefox') }
    it { expect(bug_report.referrer).to eq('/index') }

    it { is_expected.to_not validate_inclusion_of(:rating).in_array(('1'..'5').to_a) }
    it { is_expected.to validate_presence_of(:event) }
    it { is_expected.to validate_presence_of(:outcome) }
    it { is_expected.to_not validate_presence_of(:case_number) }
    it { is_expected.to be_bug_report }
    it { is_expected.not_to be_feedback }

    describe '#save' do
      context 'when valid and successful' do
        let(:ticket) { instance_double(ZendeskAPI::Ticket) }

        before do
          allow(ZendeskAPI::Ticket).to receive(:create!).and_return(ticket)
          allow(ZendeskSender).to receive(:send!)
        end

        it 'calls zendesk sender' do
          bug_report.save
          expect(ZendeskSender).to have_received(:send!)
        end

        it { expect(bug_report.save).to be_truthy }

        it 'stores success message on object' do
          bug_report.save
          expect(bug_report.response_message).to eq('Fault reported')
        end
      end

      context 'when bug report has no outcome' do
        before { bug_report.outcome = nil }

        it { expect(bug_report.save).to be_falsey }
      end

      context 'when bug report has no event' do
        before { bug_report.event = nil }

        it { expect(bug_report.save).to be_falsey }
      end

      context 'when zendesk submission fails' do
        before do
          allow(ZendeskAPI::Ticket).to receive(:create!).and_raise ZendeskAPI::Error::ClientError, 'oops, something went wrong'
          allow(LogStuff).to receive(:error)
        end

        it { expect(bug_report.save).to be_falsey }

        it 'stores failure message on object' do
          bug_report.save
          expect(bug_report.response_message).to eq('Unable to submit fault report')
        end

        it 'logs error details' do
          bug_report.save
          expect(LogStuff).to have_received(:error).with(class: described_class.to_s, action: 'save', error_class: 'ZendeskAPI::Error::ClientError', error: 'oops, something went wrong')
        end
      end

      context 'when slack notifications are enabled' do
        let(:ticket) { instance_double(ZendeskAPI::Ticket) }
        let(:notifier) { instance_double(SlackNotifier) }
        let(:notifier_args) do
          {
            icon: ':zen:',
            title: 'Bug report (test)',
            message: 'case_number: XXX - event: lorem - outcome: ipsum - email: example@example.com'
          }
        end

        before do
          allow(Settings).to receive(:slack_bug_reports_enabled?).and_return true
          allow(ZendeskAPI::Ticket).to receive(:create!).and_return(ticket)
          allow(ZendeskSender).to receive(:send!)
          allow(SlackNotifier).to receive(:new).and_return(notifier)
          allow(notifier).to receive(:build_payload)
          allow(notifier).to receive(:send_message)

          bug_report.save
        end

        it 'creates a new SlackNotifier' do
          expect(SlackNotifier).to have_received(:new)
        end

        it 'builds the payload with the notifier arguments' do
          expect(notifier).to have_received(:build_payload).with(**notifier_args)
        end

        it 'sends the message with the notifier' do
          expect(notifier).to have_received(:send_message)
        end
      end
    end

    describe '#subject' do
      it 'returns the subject heading' do
        expect(bug_report.subject).to eq('Bug report (test)')
      end
    end

    describe '#description' do
      it 'returns the description' do
        expect(bug_report.description).to eq('case_number: XXX - event: lorem - outcome: ipsum - email: example@example.com')
      end
    end

    describe '#is?' do
      context 'with feedback type' do
        it { expect(bug_report.is?(:feedback)).to be false }
      end

      context 'with bug report type' do
        it { expect(bug_report.is?(:bug_report)).to be true }
      end
    end
  end
end
