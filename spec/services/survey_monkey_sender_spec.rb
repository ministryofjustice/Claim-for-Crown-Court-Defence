RSpec.describe SurveyMonkeySender do
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
        Feedback.new(
          task: '1', rating: '1', comment: 'A comment', reason: ['', '1', '3'], other_reason: 'Another reason'
        )
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
      let(:feedback) { Feedback.new(task: nil, rating: nil, comment: 'A comment', reason: [''], other_reason: nil) }

      it { expect(survey_monkey).to have_received(:add_page).with(:feedback, comments: 'A comment') }
    end
  end

  describe '#send_response' do
    subject(:send_response) { sender.send_response }

    context 'with a sucessful submission' do
      before { allow(survey_monkey).to receive(:submit).and_return({ id: 123, success: true }) }

      it { is_expected.to eq({ id: 123, success: true }) }
    end

    context 'with an unsucessful submission' do
      before { allow(survey_monkey).to receive(:submit).and_return({ success: false, error_code: 1011 }) }

      it { is_expected.to eq({ success: false, error_code: 1011 }) }
    end
  end
end
