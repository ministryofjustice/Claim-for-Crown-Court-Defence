RSpec.describe SurveyMonkey::Question::Checkboxes do
  subject(:question) { described_class.new(id, answers:) }

  let(:id) { 999 }

  describe '#parse' do
    subject(:parse) { question.parse(responses) }

    let(:answers) { { one: 2, three: 4, five: 6 } }

    context 'with valid responses' do
      let(:responses) { [:one, :five] }

      it { is_expected.to be_a SurveyMonkey::Answer::Checkboxes }
      it { expect(parse.to_h[:id]).to eq '999' }
      it { expect(parse.to_h[:answers]).to contain_exactly({ choice_id: '2' }, { choice_id: '6' }) }
    end

    context 'with an invalid response' do
      let(:responses) { [:one, :fish] }

      it { expect { parse }.to raise_error(SurveyMonkey::UnregisteredResponse) }
    end

    context 'with and option for other comments' do
      let(:answers) { { one: 2, three: 4, five: { id: 6, other: true } } }

      context 'with other comments' do
        let(:responses) { [:five, { other: 'Hello' }] }

        it { expect(parse.to_h[:answers]).to include({ other_id: '6', text: 'Hello' }) }
      end

      context 'without other comments' do
        let(:responses) { [:five] }

        it { expect(parse.to_h[:answers]).to include({ other_id: '6', text: '' }) }
      end
    end
  end
end
