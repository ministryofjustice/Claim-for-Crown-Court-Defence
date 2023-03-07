RSpec.describe SurveyMonkey::Question::Radio do
  subject(:question) { described_class.new(id, answers:) }

  let(:id) { 999 }

  describe '#parse' do
    subject(:parse) { question.parse(response) }

    let(:answers) { { one: 2, three: 4 } }

    context 'with a valid response' do
      let(:response) { :one }

      it { is_expected.to be_a SurveyMonkey::Answer::Radio }
      it { expect(parse.to_h[:id]).to eq '999' }
      it { expect(parse.to_h[:answers]).to contain_exactly({ choice_id: '2' }) }
    end

    context 'with an invalid response' do
      let(:response) { :fish }

      it { expect { parse }.to raise_error(SurveyMonkey::UnregisteredResponse) }
    end
  end
end
