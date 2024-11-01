require 'rails_helper'

RSpec.describe Feedback do
  let(:params) do
    {
      user_agent: 'Firefox',
      referrer: '/index'
    }
  end

  it { is_expected.to validate_inclusion_of(:type).in_array(%w[feedback bug_report]) }

  shared_examples 'Feedback submission' do
    let(:feedback_params) do
      params.merge(
        type: 'feedback',
        task: '1',
        sender:,
        rating: '4',
        comment: 'lorem ipsum',
        reason: ['', '1', '2'],
        other_reason: 'dolor sit'
      )
    end

    it { expect(feedback.task).to eq '1' }
    it { expect(feedback.rating).to eq '4' }
    it { expect(feedback.comment).to eq 'lorem ipsum' }
    it { expect(feedback.reason).to eq %w[1 2] }
    it { expect(feedback.other_reason).to eq 'dolor sit' }

    describe '#save' do
      let(:save) { feedback.save }

      context 'when valid and successful' do
        before do
          allow(sender)
            .to receive(:call)
            .and_return({ success: true, response_message: 'Feedback submitted' })
        end

        it 'calls the correct sender' do
          save
          expect(sender).to have_received(:call)
        end

        it { expect(save).to be_truthy }

        it 'stores success message on object' do
          save
          expect(feedback.response_message).to eq('Feedback submitted')
        end
      end

      context 'when submission fails' do
        before do
          allow(sender)
            .to receive(:call)
            .and_return({ success: false, response_message: 'Unable to submit feedback' })
        end

        it { expect(feedback.save).to be_falsey }

        it 'stores failure message on object' do
          feedback.save
          expect(feedback.response_message).to eq('Unable to submit feedback')
        end
      end
    end

    describe '#is?' do
      context 'with feedback type' do
        it { expect(feedback.is?(:feedback)).to be true }
      end

      context 'with bug_report type' do
        it { expect(feedback.is?(:bug_report)).to be false }
      end
    end
  end

  context 'with SurveyMonkey Feedback' do
    subject(:feedback) { described_class.new(feedback_params) }

    let(:sender) { SurveyMonkeySender::Feedback }

    include_examples 'Feedback submission'
  end

  context 'with Zendesk Feedback' do
    subject(:feedback) { described_class.new(feedback_params) }

    let(:sender) { ZendeskSender }

    include_examples 'Feedback submission'
  end

  context 'with no sender passed as an argument' do
    subject(:feedback) { described_class.new(feedback_params) }

    let(:feedback_params) do
      params.merge(
        type: 'feedback',
        task: '1',
        rating: '4',
        comment: 'lorem ipsum',
        reason: ['', '1', '2'],
        other_reason: 'dolor sit'
      )
    end

    it 'defaults to nil' do
      expect(feedback.instance_variable_get(:@sender)).to be_nil
    end
  end

  context 'with a bug report' do
    subject(:bug_report) { described_class.new(bug_report_params) }

    let(:bug_report_params) do
      params.merge(
        type: 'bug_report',
        case_number: 'XXX',
        sender: ZendeskSender,
        event: 'lorem',
        outcome: 'ipsum',
        email: 'example@example.com'
      )
    end

    it { expect(bug_report.email).to eq('example@example.com') }
    it { expect(bug_report.case_number).to eq('XXX') }
    it { expect(bug_report.event).to eq('lorem') }
    it { expect(bug_report.outcome).to eq('ipsum') }
    it { expect(bug_report.user_agent).to eq('Firefox') }
    it { expect(bug_report.referrer).to eq('/index') }

    it { is_expected.not_to validate_inclusion_of(:rating).in_array(('1'..'5').to_a) }
    it { is_expected.to validate_presence_of(:event) }
    it { is_expected.to validate_presence_of(:outcome) }
    it { is_expected.not_to validate_presence_of(:case_number) }

    describe '#save' do
      context 'when valid and successful' do
        before do
          allow(ZendeskSender)
            .to receive(:call)
            .and_return({ success: true, response_message: 'Bug Report submitted' })
        end

        it 'calls zendesk sender' do
          bug_report.save
          expect(ZendeskSender).to have_received(:call)
        end

        it { expect(bug_report.save).to be_truthy }

        it 'stores success message on object' do
          bug_report.save
          expect(bug_report.response_message).to eq('Bug Report submitted')
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
          allow(ZendeskSender)
            .to receive(:call)
            .and_return({ success: false, response_message: 'Unable to submit bug report' })
        end

        it { expect(bug_report.save).to be_falsey }

        it 'stores failure message on object' do
          bug_report.save
          expect(bug_report.response_message).to eq('Unable to submit bug report')
        end
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
