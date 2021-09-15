RSpec.describe SurveyMonkey::Answer::Text do
  subject(:answer) { described_class.new(question: question_id, answer: text) }

  describe '#to_h' do
    subject { answer.to_h }

    let(:question_id) { 123 }
    let(:text) { 'It is a far, far better thing that I do, than I have ever done;' }

    it { is_expected.to eq({ id: '123', answers: [{ text: text }] }) }
  end
end
