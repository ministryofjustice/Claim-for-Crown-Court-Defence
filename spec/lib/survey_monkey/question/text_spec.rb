RSpec.describe SurveyMonkey::Question::Text do
  subject(:question) { described_class.new(id) }

  let(:id) { 999 }

  describe '#parse' do
    subject { question.parse(text) }

    context 'with a comment' do
      let(:text) { 'A comment' }

      it { is_expected.to be_a SurveyMonkey::Answer::Text }
    end
  end
end
