# frozen_string_literal: true

RSpec.shared_examples 'translation not found' do
  it { expect(emt.translation_found?).to be false }
  it { expect(emt.long_message).to be_nil }
  it { expect(emt.short_message).to be_nil }
  it { expect(emt.api_message).to be_nil }
end

RSpec.describe ErrorMessageTranslator do
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

  let(:emt) { described_class.new(translations, key, error) }
  let(:key) { :name }
  let(:error) { 'cannot_be_blank' }

  it 'responds to long_message, short_message, api_message' do
    expect(emt).to respond_to :long_message
    expect(emt).to respond_to :short_message
    expect(emt).to respond_to :api_message
  end

  context 'with single level translations' do
    context 'when key and error exists' do
      let(:key) { :name }
      let(:error) { 'cannot_be_blank' }

      it 'returns top level long and short messages' do
        expect(emt.translation_found?).to be true
        expect(emt.long_message).to eq 'The claimant name must not be blank, please enter a name'
        expect(emt.short_message).to eq 'Enter a name'
        expect(emt.api_message).to eq 'The claimant name must not be blank'
      end
    end

    context 'when key does not exist' do
      let(:key) { :stepmother }
      let(:error) { 'too_long' }

      include_examples 'translation not found'
    end

    context 'when key exists but error does not exist' do
      let(:key) { :name }
      let(:error) { 'rubbish' }

      include_examples 'translation not found'
    end
  end

  context 'with has_many sub-model translations' do
    context 'when key and error exist' do
      let(:key) { :defendant_2_first_name }
      let(:error) { 'blank' }

      it 'returns defendant 2 error messages' do
        expect(emt.translation_found?).to be true
        expect(emt.long_message).to eq 'Enter a first name for the second defendant'
        expect(emt.short_message).to eq 'Cannot be blank'
        expect(emt.api_message).to eq 'The first name for the second defendant must not be blank'
      end
    end

    context 'when key for submodel does not exist in base model' do
      let(:key) { :person_2_first_name }
      let(:error) { 'blank' }

      include_examples 'translation not found'
    end

    context 'when key for submodel exists but key for field in submodel does not' do
      let(:key) { :defendant_2_age }
      let(:error) { 'blank' }

      include_examples 'translation not found'
    end

    context 'when key for submodel and field on submodel exists but error does not' do
      let(:key) { :defendant_2_first_name }
      let(:error) { 'foo' }

      include_examples 'translation not found'
    end
  end

  context 'with has_one sub-model translations' do
    context 'when nested key and error exists' do
      let(:key) { 'fixed_fee.quantity' }
      let(:error) { 'invalid' }

      it 'returns error defaulting error message' do
        expect(emt.translation_found?).to be true
        expect(emt.long_message).to eq 'Enter a valid quantity for the fixed fee'
      end
    end
  end

  context 'with has_many sub-sub-model translations' do
    context 'when nested keys and errors exist' do
      let(:key) { :defendant_5_representation_order_2_maat_reference }
      let(:error) { 'blank' }

      it 'returns defendant 5 reporder 2 errors' do
        expect(emt.translation_found?).to be true
        expect(emt.long_message).to eq 'The MAAT Reference must be 7-10 numeric digits for the second representation order of the fifth defendant'
        expect(emt.short_message).to eq 'Invalid format'
        expect(emt.api_message).to eq 'The MAAT Reference must be 7-10 numeric digits for the second representation order of the fifth defendant'
      end
    end

    context 'when key for sub-sub-model does not exist' do
      let(:key) { :defendant_5_court_order_2_maat_reference }
      let(:error) { 'blank' }

      include_examples 'translation not found'
    end

    context 'when key for field on sub sub model does not exist' do
      let(:key) { :defendant_5_representation_order_2_court }
      let(:error) { 'blank' }

      include_examples 'translation not found'
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
    it { expect(emt.send(:to_ordinal, '67')).to eq '67th' }
  end
end
