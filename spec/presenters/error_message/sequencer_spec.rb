# frozen_string_literal: true

RSpec.describe ErrorMessage::Sequencer do
  subject(:sequencer) { described_class.new(translations: translations) }

  let(:translations) do
    {
      name: {
        _seq: 60,
        cannot_be_blank: {
          long: 'The claimant name must not be blank, please enter a name',
          short: 'Enter a name',
          api: 'The claimant name must not be blank'
        },
        too_long: {
          long: 'The name cannot be longer than 50 characters',
          short: 'Too long',
          api: 'The name cannot be longer than 50 characters'
        }
      },
      defendant: {
        _seq: 40,
        first_name: {
          _seq: 10,
          blank: {
            long: 'Enter a first name for the defendant',
            short: 'Enter a first name',
            api: 'The first name for the defendant must not be blank'
          }
        }
      }
    }.with_indifferent_access
  end

  describe '#generate' do
    subject { sequencer.generate(key) }

    context 'when the attribute is present' do
      let(:key) { 'name' }

      it { is_expected.to eq(60) }
    end

    context 'with a nested attribute' do
      let(:key) { 'defendant_1_first_name' }

      it { is_expected.to eq(50) }
    end

    context 'when the attribute is not present' do
      let(:key) { 'nokey' }

      it { is_expected.to eq(99_999) }
    end
  end
end
