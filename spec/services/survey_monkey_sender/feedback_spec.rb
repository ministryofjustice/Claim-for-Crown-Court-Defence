RSpec.describe SurveyMonkeySender::Feedback do
  subject(:sender) { described_class.new(feedback) }

  let(:feedback) { Feedback.new }
  let(:survey_monkey) { instance_double(SurveyMonkey::Response) }

  before do
    allow(SurveyMonkey::Response).to receive(:new).and_return(survey_monkey)
    allow(survey_monkey).to receive(:add_page)
  end

  describe '.new' do
    subject(:sender) { described_class.new(feedback) }

    let(:survey_monkey) { instance_double(SurveyMonkey::Response) }

    before { sender }

    context 'with all feedback options' do
      let(:feedback) do
        Feedback.new(task: '1', rating: '1', comment: 'A comment',
                     reason: %w[1 3], other_reason: 'Another reason')
      end

      it do
        expect(survey_monkey).to have_received(:add_page)
          .with(
            :feedback, tasks: '1', ratings: '1', comments: 'A comment',
                       reasons: ['1', '3', { other: 'Another reason' }]
          )
      end
    end

    context 'with only a comment' do
      let(:feedback) do
        Feedback.new(task: nil, rating: nil, comment: 'A comment', reason: [], other_reason: nil)
      end

      it { expect(survey_monkey).to have_received(:add_page).with(:feedback, comments: 'A comment') }
    end

    context 'with a nil reason' do
      let(:feedback) do
        Feedback.new(task: nil, rating: nil, comment: 'A comment', reason: nil, other_reason: nil)
      end

      it { expect(survey_monkey).to have_received(:add_page).with(:feedback, comments: 'A comment') }
    end
  end

  describe '#call' do
    subject(:call) { sender.call }

    context 'with a successful submission' do
      before { allow(survey_monkey).to receive(:submit).and_return({ id: 123, success: true }) }

      it { is_expected.to eq({ success: true, response_message: 'Feedback submitted' }) }
    end

    context 'with an unsuccessful submission' do
      before { allow(survey_monkey).to receive(:submit).and_return({ success: false, error_code: 1011 }) }

      it { is_expected.to eq({ success: false, response_message: 'Unable to submit feedback [1011]' }) }
    end
  end
end
