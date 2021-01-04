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
    let(:feedback_params) do
      params.merge(type: 'feedback', comment: 'lorem ipsum', rating: '4')
    end

    subject { Feedback.new(feedback_params) }

    it { is_expected.to validate_inclusion_of(:rating).in_array(('1'..'5').to_a) }

    describe '#initialize' do
      it 'sets the email' do
        expect(subject.email).to eq('example@example.com')
      end

      it 'sets the comment' do
        expect(subject.comment).to eq('lorem ipsum')
      end

      it 'sets the rating' do
        expect(subject.rating).to eq('4')
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

        context 'and the comment is nil' do
          let(:feedback_params) do
            params.merge(type: 'feedback', comment: nil, rating: '4')
          end

          it 'does not create a zendesk ticket but still returns true' do
            expect(ZendeskSender).not_to receive(:send!)
            expect(subject.save).to eq(true)
          end
        end

        context 'and the comment is empty' do
          let(:feedback_params) do
            params.merge(type: 'feedback', comment: '', rating: '4')
          end

          it 'does not create a zendesk ticket but still returns true' do
            expect(ZendeskSender).not_to receive(:send!)
            expect(subject.save).to eq(true)
          end
        end
      end

      context 'when invalid' do
        it 'returns false' do
          subject.rating = nil
          expect(subject.save).to eq(false)
        end
      end
    end

    describe '#subject' do
      it 'returns the subject heading' do
        expect(subject.subject).to eq('Feedback (test)')
      end
    end

    describe '#description' do
      it 'returns the description' do
        expect(subject.description).to eq('rating: 4 - comment: lorem ipsum - email: example@example.com')
      end
    end

    describe '#is?' do
      context 'feedback' do
        it 'should be true for feedback' do
          expect(subject.is?(:feedback)).to eq(true)
        end
      end

      context 'bug report' do
        it 'should be false for feedback' do
          expect(subject.is?(:bug_report)).to eq(false)
        end
      end
    end

    describe '#feedback?' do
      it 'should be feedback' do
        expect(subject).to be_feedback
      end
    end

    describe '#bug_report?' do
      it 'should not be a bug report' do
        expect(subject).to_not be_bug_report
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
        it 'should be false for bug report' do
          expect(subject.is?(:feedback)).to eq(false)
        end
      end

      context 'bug report' do
        it 'should be true for bug report' do
          expect(subject.is?(:bug_report)).to eq(true)
        end
      end
    end

    describe '#feedback?' do
      it 'should not be feedback' do
        expect(subject).to_not be_feedback
      end
    end

    describe '#bug_report?' do
      it 'should be a bug report' do
        expect(subject).to be_bug_report
      end
    end
  end
end
