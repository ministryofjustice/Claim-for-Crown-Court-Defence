require 'rails_helper'

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
          'long' => 'Enter a valid quantity for the #{fixed_fee}',
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

  let(:emt) { ErrorMessageTranslator.new(translations, key, error) }

  context 'provides readble message attributes' do
    let(:key)   { :name }
    let(:error) { 'cannot_be_blank' }

    it 'should respond to long_message, short_message, api_message' do
      expect(emt).to respond_to :long_message
      expect(emt).to respond_to :short_message
      expect(emt).to respond_to :api_message
    end
  end

  context 'single_level_translations' do
    let(:key)           { :name }
    let(:error)         { 'cannot_be_blank' }

    context 'key and error exists in translations table' do
      it 'returns top level long and short messages' do
        expect(emt.translation_found?).to be true
        expect(emt.long_message).to eq 'The claimant name must not be blank, please enter a name'
        expect(emt.short_message).to eq 'Enter a name'
        expect(emt.api_message).to eq 'The claimant name must not be blank'
      end
    end

    context 'key does not exist in translations table' do
      let(:key)           { :stepmother }
      let(:error)         { 'too_long' }
      it 'returns nil and responds true to unable_to_find_translation' do
        expect_translation_not_found(emt)
      end
    end

    context 'key exists but error does not exist in translations table' do
      let(:key)           { :name }
      let(:error)         { 'rubbish' }
      it 'returns nil and responds true to unable_to_find_translation' do
        expect_translation_not_found(emt)
      end
    end
  end

  context 'sub-model translations' do
    context 'has_many relations' do
      context 'key and error exist in translations table' do
        let(:key)           { :defendant_2_first_name }
        let(:error)         { 'blank' }
        it 'returns defendant 2 error messages' do
          expect(emt.translation_found?).to be true
          expect(emt.long_message).to eq 'Enter a first name for the second defendant'
          expect(emt.short_message).to eq 'Cannot be blank'
          expect(emt.api_message).to eq 'The first name for the second defendant must not be blank'
        end
      end

      context 'key for submodel does not exist in base model' do
        let(:key) { :person_2_first_name }
        let(:error) { 'blank' }
        it 'returns defendant 2 error messages' do
          expect_translation_not_found(emt)
        end
      end

      context 'key for submodel exists but key for field in submodel does not' do
        let(:key) { :defendant_2_age }
        let(:error) { 'blank' }
        it 'returns defendant 2 error messages' do
          expect_translation_not_found(emt)
        end
      end

      context 'key for submodel and field on submodel exists but error does not' do
        let(:key) { :defendant_2_first_name }
        let(:error) { 'baslderdash' }
        it 'returns defendant 2 error messages' do
          expect_translation_not_found(emt)
        end
      end
    end

    context 'has_one relations' do
      let(:key) { 'fixed_fee.quantity' }
      let(:error) { 'invalid' }
      it 'returns error defaulting error message' do
        expect(emt.translation_found?).to be true
        expect(emt.long_message).to eq 'Enter a valid quantity for the fixed fee'
      end
    end
  end

  context 'sub-sub-model translations' do
    context 'all keys and errors exist' do
      let(:key)           { :defendant_5_representation_order_2_maat_reference }
      let(:error)         { 'blank' }
      it 'returns defendant 5 reporder 2 errors' do
        expect(emt.translation_found?).to be true
        expect(emt.long_message).to   eq 'The MAAT Reference must be 7-10 numeric digits for the second representation order of the fifth defendant'
        expect(emt.short_message).to  eq 'Invalid format'
        expect(emt.api_message).to    eq 'The MAAT Reference must be 7-10 numeric digits for the second representation order of the fifth defendant'
      end
    end

    context 'key for sub sub model does not exist' do
      let(:key)           { :defendant_5_court_order_2_maat_reference }
      let(:error)         { 'blank' }
      it 'returns defendant 5 reporder 2 errors' do
        expect_translation_not_found(emt)
      end
    end

    context 'key for field on sub sub model does not exist' do
      let(:key)           { :defendant_5_representation_order_2_court }
      let(:error)         { 'blank' }
      it 'returns defendant 5 reporder 2 errors' do
        expect_translation_not_found(emt)
      end
    end

    context 'key for error on sub sub model does not exist' do
      let(:key)           { :defendant_5_representation_order_2_maat_reference }
      let(:error)         { 'no_such_error' }
      it 'returns defendant 5 reporder 2 errors' do
        expect_translation_not_found(emt)
      end
    end
  end

  describe 'to_ordinal' do
    let(:key)           { :defendant_5_representation_order_2_maat_reference }
    let(:error)         { 'no_such_error' }

    it 'returns empty string for 0' do
      expect(emt.send(:to_ordinal, 0)).to be_empty
      expect(emt.send(:to_ordinal, '0')).to be_empty
    end

    it 'returns words for 1 to 10' do
      expect(emt.send(:to_ordinal, '1')).to eq 'first'
      expect(emt.send(:to_ordinal, '2')).to eq 'second'
      expect(emt.send(:to_ordinal, '3')).to eq 'third'
      expect(emt.send(:to_ordinal, '4')).to eq 'fourth'
      expect(emt.send(:to_ordinal, '5')).to eq 'fifth'
      expect(emt.send(:to_ordinal, '6')).to eq 'sixth'
      expect(emt.send(:to_ordinal, '7')).to eq 'seventh'
      expect(emt.send(:to_ordinal, '8')).to eq 'eighth'
      expect(emt.send(:to_ordinal, '9')).to eq 'ninth'
      expect(emt.send(:to_ordinal, '10')).to eq 'tenth'
    end

    it 'returns ordinals for 11+' do
      expect(emt.send(:to_ordinal, '11')).to eq '11th'
      expect(emt.send(:to_ordinal, '12')).to eq '12th'
      expect(emt.send(:to_ordinal, '21')).to eq '21st'
      expect(emt.send(:to_ordinal, '43')).to eq '43rd'
      expect(emt.send(:to_ordinal, '67')).to eq '67th'
    end
  end

  # local helpers
  # -------------
  def expect_translation_not_found(emt)
    expect(emt.translation_found?).to be false
    expect(emt.long_message).to   be_nil
    expect(emt.short_message).to  be_nil
    expect(emt.api_message).to    be_nil
  end
end
