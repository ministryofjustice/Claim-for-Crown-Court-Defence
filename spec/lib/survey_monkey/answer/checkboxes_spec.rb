RSpec.describe SurveyMonkey::Answer::Checkboxes do
  subject(:answer) { described_class.new(**options) }

  let(:options) { { question: question_id, answers: choices } }

  describe '#to_h' do
    subject { answer.to_h }

    let(:question_id) { 123 }
    let(:choices) { [987, 654] }

    context 'with simple answers' do
      it { is_expected.to eq({ id: '123', answers: [{ choice_id: '987' }, { choice_id: '654' }] }) }
    end

    context 'with a selected other option' do
      let(:options) { super().merge(other: 987, other_text: 'Hello') }

      it { is_expected.to eq({ id: '123', answers: [{ other_id: '987', text: 'Hello' }, { choice_id: '654' }] }) }
    end
  end
end
