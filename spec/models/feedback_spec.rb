require 'rails_helper'

RSpec.describe Feedback, type: :model do
  let(:params) do
    {
      email: 'example@example.com',
      user_agent: 'Firefox',
      referrer: '/index'
    }
  end

  it { is_expected.to validate_inclusion_of(:type).in_array(%w(feedback bug_report)) }

  context 'feedback' do
    subject(:feedback) { Feedback.new(feedback_params) }

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

      before { allow(SurveyMonkeySender).to receive(:send_response).and_return({ id: 123, success: true }) }

      context 'when Survey Monkey succeeds' do
        it 'sends the response to Survey Monkey' do
          save
          expect(SurveyMonkeySender).to have_received(:send_response).with(feedback)
        end
      end
    end

    describe '#is?' do
      context 'feedback' do
        it 'is true for feedback' do
          expect(feedback.is?(:feedback)).to eq(true)
        end
      end

      context 'bug report' do
        it 'is false for feedback' do
          expect(feedback.is?(:bug_report)).to eq(false)
        end
      end
    end
  end

  context 'bug report' do
    let(:bug_report_params) do
      params.merge(type: 'bug_report', case_number: 'XXX', event: 'lorem', outcome: 'ipsum')
    end

    subject { Feedback.new(bug_report_params) }

    it { is_expected.to_not validate_inclusion_of(:rating).in_array(('1'..'5').to_a) }
    it { is_expected.to validate_presence_of(:event) }
    it { is_expected.to validate_presence_of(:outcome) }
    it { is_expected.to_not validate_presence_of(:case_number) }

    describe '#initialize' do
      it 'sets the email' do
        expect(subject.email).to eq('example@example.com')
      end

      it 'sets the case_number' do
        expect(subject.case_number).to eq('XXX')
      end

      it 'sets the event' do
        expect(subject.event).to eq('lorem')
      end

      it 'sets the outcome' do
        expect(subject.outcome).to eq('ipsum')
      end

      it 'sets the user_agent' do
        expect(subject.user_agent).to eq('Firefox')
      end

      it 'sets the referrer' do
        expect(subject.referrer).to eq('/index')
      end
    end

    describe '#save' do
      before do
        allow(ZendeskAPI::Ticket).to receive(:create!).and_return(true)
      end

      context 'when valid' do
        it 'creates zendesk ticket and returns true' do
          expect(ZendeskSender).to receive(:send!)
          expect(subject.save).to eq(true)
        end
      end

      context 'when invalid' do
        it 'returns false' do
          subject.event = nil
          subject.outcome = nil
          expect(subject.save).to eq(false)
        end
      end
    end

    describe '#subject' do
      it 'returns the subject heading' do
        expect(subject.subject).to eq('Bug report (test)')
      end
    end

    describe '#description' do
      it 'returns the description' do
        expect(subject.description).to eq('case_number: XXX - event: lorem - outcome: ipsum - email: example@example.com')
      end
    end

    describe '#is?' do
      context 'feedback' do
        it 'is false for bug report' do
          expect(subject.is?(:feedback)).to eq(false)
        end
      end

      context 'bug report' do
        it 'is true for bug report' do
          expect(subject.is?(:bug_report)).to eq(true)
        end
      end
    end

    describe '#feedback?' do
      it 'is not feedback' do
        expect(subject).to_not be_feedback
      end
    end

    describe '#bug_report?' do
      it 'is a bug report' do
        expect(subject).to be_bug_report
      end
    end
  end
end
