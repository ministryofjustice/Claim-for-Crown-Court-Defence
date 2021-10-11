RSpec.describe SurveyMonkey::Answer::Radio do
  subject(:answer) { described_class.new(question: question_id, answer: choice) }

  describe '#to_h' do
    subject { answer.to_h }

    let(:question_id) { 123 }
    let(:choice) { 987 }

    it { is_expected.to eq({ id: '123', answers: [{ choice_id: '987' }] }) }
  end
end
