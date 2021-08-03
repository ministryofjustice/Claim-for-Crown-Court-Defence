# frozen_string_literal: true

RSpec.shared_examples 'translation not found' do
  it { expect(emt).not_to be_translation_found }
  it { expect(emt.long_message).to be_nil }
  it { expect(emt.short_message).to be_nil }
  it { expect(emt.api_message).to be_nil }
end

RSpec.shared_examples 'translation found' do |options|
  it { expect(emt).to be_translation_found }
  it { expect(emt.long_message).to eq(options[:long]) }
  it { expect(emt.short_message).to eq(options[:short]) }
  it { expect(emt.api_message).to eq(options[:api]) }
end

RSpec.describe ErrorMessageTranslator do
  subject(:emt) { described_class.new(translations, key, error) }

  let(:key) { :name }
  let(:error) { 'cannot_be_blank' }

  let(:translations) do
    {
      'name' => {
        '_seq' => 50,
        'cannot_be_blank' => {
          'long' => 'The claimant name must not be blank, please enter a name',
          'short' => 'Enter a name',
          'api' => 'The claimant name must not be blank'
        },
        'too_long' => {
          'long' => 'The name cannot be longer than 50 characters',
          'short' => 'Too long',
          'api' => 'The name cannot be longer than 50 characters'
        }
      },
      'date_of_birth' => {
        'too_early' => {
          'long' => 'The date of birth may not be more than 100 years old',
          'short' => 'Invalid date',
          'api' => 'The date of birth may not be more than 100 years old'
        }
      },
      'trial_date' => {
        '_seq' => 20,
        'not_future' => {
          'long' => 'The trial date may not be in the future',
          'short' => 'Invalid date',
          'api' => 'The trial date may not be in the future'
        }
      },
      'defendant' => {
        '_seq' => 30,
        'first_name' => {
          '_seq' => 10,
          'blank' => {
            'long' => "Enter a first name for the \#{defendant}",
            'short' => 'Cannot be blank',
            'api' => "The first name for the \#{defendant} must not be blank"
          }
        }
      },
      'fixed_fee' => {
        '_seq' => 600,
        'quantity' => {
          '_seq' => 30,
          'invalid' => {
            'long' => "Enter a valid quantity for the \#{fixed_fee}",
            'short' => 'Enter a valid quantity',
            'api' => 'Enter a valid quantity for the fixed fee'
          }
        }
      },
      'representation_order' => {
        '_seq' => 80,
        'maat_reference' => {
          'seq' => 20,
          'blank' => {
            'long' => "The MAAT Reference must be 7-10 numeric digits for the \#{representation_order} of the \#{defendant}",
            'short' => 'Invalid format',
            'api' => "The MAAT Reference must be 7-10 numeric digits for the \#{representation_order} of the \#{defendant}"
          }
        }
      }
    }
  end

  it { is_expected.to respond_to(:long_message, :short_message, :api_message) }

  describe '.association_key' do
    subject(:association_key) { described_class.association_key(key) }

    context 'with unnumbered key' do
      let(:key) { 'foo.bar_1_baz' }

      it { is_expected.to eq('foo_0_bar_0_baz') }
    end

    context 'with numbered key' do
      let(:key) { 'foo_0_bar_0_baz' }

      it { is_expected.to eq('foo_0_bar_0_baz') }
    end
  end

  describe '#translation_found?' do
    subject { emt.translation_found? }

    context 'when key and error exists' do
      let(:key) { :name }
      let(:error) { 'cannot_be_blank' }

      it { is_expected.to be_truthy }
    end

    context 'when key does not exist' do
      let(:key) { :foo }
      let(:error) { 'cannot_be_blank' }

      it { is_expected.to be_falsey }
    end

    context 'when message does not exist' do
      let(:key) { :name }
      let(:error) { 'bar' }

      it { is_expected.to be_falsey }
    end
  end

  context 'with single level translations' do
    context 'when key and error exists' do
      let(:key) { :name }
      let(:error) { 'cannot_be_blank' }

      it_behaves_like 'translation found',
                      long: 'The claimant name must not be blank, please enter a name',
                      short: 'Enter a name',
                      api: 'The claimant name must not be blank'
    end

    context 'when key does not exist' do
      let(:key) { :stepmother }
      let(:error) { 'too_long' }

      it_behaves_like 'translation not found'
    end

    context 'when key exists but error does not exist' do
      let(:key) { :name }
      let(:error) { 'rubbish' }

      it_behaves_like 'translation not found'
    end
  end

  context 'with has_many sub-model translations' do
    context 'when key and error exist' do
      let(:key) { :defendant_2_first_name }
      let(:error) { 'blank' }

      it_behaves_like 'translation found',
                      long: 'Enter a first name for the second defendant',
                      short: 'Cannot be blank',
                      api: 'The first name for the second defendant must not be blank'
    end

    context 'when key for submodel does not exist in base model' do
      let(:key) { :person_2_first_name }
      let(:error) { 'blank' }

      it_behaves_like 'translation not found'
    end

    context 'when key for submodel exists but key for field in submodel does not' do
      let(:key) { :defendant_2_age }
      let(:error) { 'blank' }

      it_behaves_like 'translation not found'
    end

    context 'when key for submodel and field on submodel exists but error does not' do
      let(:key) { :defendant_2_first_name }
      let(:error) { 'foo' }

      it_behaves_like 'translation not found'
    end
  end

  context 'with has_one sub-model translations' do
    context 'when nested key and error exists' do
      let(:key) { 'fixed_fee.quantity' }
      let(:error) { 'invalid' }

      it_behaves_like 'translation found',
                      long: 'Enter a valid quantity for the fixed fee',
                      short: 'Enter a valid quantity',
                      api: 'Enter a valid quantity for the fixed fee'
    end
  end

  context 'with has_many sub-sub-model translations' do
    context 'when nested keys and errors exist' do
      let(:key) { :defendant_5_representation_order_2_maat_reference }
      let(:error) { 'blank' }

      it_behaves_like 'translation found',
                      long: 'The MAAT Reference must be 7-10 numeric digits for the second representation order of the fifth defendant',
                      short: 'Invalid format',
                      api: 'The MAAT Reference must be 7-10 numeric digits for the second representation order of the fifth defendant'
    end

    context 'when key for sub-sub-model does not exist' do
      let(:key) { :defendant_5_court_order_2_maat_reference }
      let(:error) { 'blank' }

      it_behaves_like 'translation not found'
    end

    context 'when key for field on sub sub model does not exist' do
      let(:key) { :defendant_5_representation_order_2_court }
      let(:error) { 'blank' }

      it_behaves_like 'translation not found'
    end

    context 'when key for error on sub sub model does not exist' do
      let(:key) { :defendant_5_representation_order_2_maat_reference }
      let(:error) { 'no_such_error' }

      include_examples 'translation not found'
    end
  end

  describe '#to_ordinal' do
    it { expect(emt.send(:to_ordinal, 0)).to be_empty }
    it { expect(emt.send(:to_ordinal, '0')).to be_empty }
    it { expect(emt.send(:to_ordinal, '1')).to eq 'first' }
    it { expect(emt.send(:to_ordinal, '10')).to eq 'tenth' }
    it { expect(emt.send(:to_ordinal, '11')).to eq '11th' }
    it { expect(emt.send(:to_ordinal, '42')).to eq '42nd' }
    it { expect(emt.send(:to_ordinal, '63')).to eq '63rd' }
  end
end
