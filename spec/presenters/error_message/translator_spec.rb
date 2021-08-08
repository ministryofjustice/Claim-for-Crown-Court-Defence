# frozen_string_literal: true

RSpec.shared_context 'with custom error messages' do
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
            'api' => "Enter a valid quantity for the \#{fixed_fee}"
          }
        }
      },
      'representation_order' => {
        '_seq' => 80,
        'maat_reference' => {
          'seq' => 20,
          'blank' => {
            'long' => "Enter a valid MAAT reference for the \#{representation_order} of the \#{defendant}",
            'short' => 'Invalid format',
            'api' => "Enter a valid MAAT reference for the \#{representation_order} of the \#{defendant}"
          }
        }
      }
    }
  end
end

RSpec.shared_examples 'message found' do |options|
  it { expect(message.long).to eq(options[:long]) }
  it { expect(message.short).to eq(options[:short]) }
  it { expect(message.api).to eq(options[:api]) }
end

RSpec.describe ErrorMessage::Translator do
  subject(:translator) { described_class.new(translations) }

  include_context 'with custom error messages'

  describe '#message' do
    subject(:message) { translator.message(key, error) }

    context 'with single level translations' do
      context 'when key and error exists' do
        let(:key) { :name }
        let(:error) { 'cannot_be_blank' }

        it_behaves_like 'message found',
                        long: 'The claimant name must not be blank, please enter a name',
                        short: 'Enter a name',
                        api: 'The claimant name must not be blank'
      end

      context 'when key does not exist' do
        let(:key) { :stepmother }
        let(:error) { 'too_long' }

        it_behaves_like 'message found',
                        long: 'Stepmother too long',
                        short: 'Too long',
                        api: 'Stepmother too long'
      end

      context 'when key exists but error does not exist' do
        let(:key) { :name }
        let(:error) { 'rubbish' }

        it_behaves_like 'message found',
                        long: 'Name rubbish',
                        short: 'Rubbish',
                        api: 'Name rubbish'
      end
    end

    context 'with has_many sub-model translations' do
      context 'when key and error exist' do
        let(:key) { :defendant_2_first_name }
        let(:error) { 'blank' }

        it_behaves_like 'message found',
                        long: 'Enter a first name for the second defendant',
                        short: 'Cannot be blank',
                        api: 'The first name for the second defendant must not be blank'
      end

      context 'when key for submodel does not exist in base model' do
        let(:key) { :person_2_first_name }
        let(:error) { 'blank' }

        it_behaves_like 'message found',
                        long: 'Person 2 first name blank',
                        short: 'Blank',
                        api: 'Person 2 first name blank'
      end

      context 'when key for submodel exists but key for field in submodel does not' do
        let(:key) { :defendant_2_age }
        let(:error) { 'blank' }

        it_behaves_like 'message found',
                        long: 'Defendant 2 age blank',
                        short: 'Blank',
                        api: 'Defendant 2 age blank'
      end

      context 'when key for submodel and field on submodel exists but error does not' do
        let(:key) { :defendant_2_first_name }
        let(:error) { 'foo' }

        it_behaves_like 'message found',
                        long: 'Defendant 2 first name foo',
                        short: 'Foo',
                        api: 'Defendant 2 first name foo'
      end
    end

    context 'with has_one sub-model translations' do
      context 'when nested key and error exists' do
        let(:key) { 'fixed_fee.quantity' }
        let(:error) { 'invalid' }

        it_behaves_like 'message found',
                        long: 'Enter a valid quantity for the first fixed fee',
                        short: 'Enter a valid quantity',
                        api: 'Enter a valid quantity for the first fixed fee'
      end
    end

    context 'with has_many sub-sub-model translations' do
      context 'when nested keys and errors exist' do
        let(:key) { :defendant_5_representation_order_2_maat_reference }
        let(:error) { 'blank' }

        it_behaves_like 'message found',
                        long: 'Enter a valid MAAT reference for the second representation order of the fifth defendant',
                        short: 'Invalid format',
                        api: 'Enter a valid MAAT reference for the second representation order of the fifth defendant'
      end

      context 'when key for sub-sub-model does not exist' do
        let(:key) { :defendant_5_court_order_2_maat_reference }
        let(:error) { 'blank' }

        it_behaves_like 'message found',
                        long: 'Defendant 5 court order 2 maat reference blank',
                        short: 'Blank',
                        api: 'Defendant 5 court order 2 maat reference blank'
      end

      context 'when key for field on sub sub model does not exist' do
        let(:key) { :defendant_5_representation_order_2_court }
        let(:error) { 'blank' }

        it_behaves_like 'message found',
                        long: 'Defendant 5 representation order 2 court blank',
                        short: 'Blank',
                        api: 'Defendant 5 representation order 2 court blank'
      end

      context 'when key for error on sub sub model does not exist' do
        let(:key) { :defendant_5_representation_order_2_maat_reference }
        let(:error) { 'no_such_error' }

        it_behaves_like 'message found',
                        long: 'Defendant 5 representation order 2 maat reference no such error',
                        short: 'No such error',
                        api: 'Defendant 5 representation order 2 maat reference no such error'
      end
    end

    context 'with rails nested errors' do
      context 'with has_many sub-model translations' do
        context 'when key and error exist' do
          let(:key) { 'defendants_attributes_0_first_name' }
          let(:error) { 'blank' }

          it_behaves_like 'message found',
                          long: 'Enter a first name for the first defendant',
                          short: 'Cannot be blank',
                          api: 'The first name for the first defendant must not be blank'
        end

        context 'when key for submodel does not exist in base model' do
          let(:key) { 'foos_attributes_0_age' }
          let(:error) { 'blank' }

          it_behaves_like 'message found',
                          long: 'Foo 0 age blank',
                          short: 'Blank',
                          api: 'Foo 0 age blank'
        end

        context 'when key for submodel exists but key for attribute on submodel does not' do
          let(:key) { 'defendants_attributes_0_age' }
          let(:error) { 'blank' }

          it_behaves_like 'message found',
                          long: 'Defendant 0 age blank',
                          short: 'Blank',
                          api: 'Defendant 0 age blank'
        end

        context 'when key for submodel and attribute on submodel exists but error does not' do
          let(:key) { 'defendants_attributes_0_first_name' }
          let(:error) { 'bar' }

          it_behaves_like 'message found',
                          long: 'Defendant 0 first name bar',
                          short: 'Bar',
                          api: 'Defendant 0 first name bar'
        end
      end

      context 'with has_many sub-sub-model translations' do
        context 'when nested keys and errors exist' do
          let(:key) { :defendants_attributes_4_representation_orders_attributes_1_maat_reference }
          let(:error) { 'blank' }

          it_behaves_like 'message found',
                          long: 'Enter a valid MAAT reference for the second representation order of the fifth defendant',
                          short: 'Invalid format',
                          api: 'Enter a valid MAAT reference for the second representation order of the fifth defendant'
        end

        context 'when key for sub-sub-model does not exist' do
          let(:key) { :defendants_attributes_4_foobars_attributes_1_maat_reference }
          let(:error) { 'blank' }

          it_behaves_like 'message found',
                          long: 'Defendant 4 foobar 1 maat reference blank',
                          short: 'Blank',
                          api: 'Defendant 4 foobar 1 maat reference blank'
        end

        context 'when key for attribute on sub-sub-model does not exist' do
          let(:key) { :defendants_attributes_4_representation_orders_attributes_1_foobar }
          let(:error) { 'blank' }

          it_behaves_like 'message found',
                          long: 'Defendant 4 representation order 1 foobar blank',
                          short: 'Blank',
                          api: 'Defendant 4 representation order 1 foobar blank'
        end

        context 'when key for error on sub-sub-model does not exist' do
          let(:key) { :defendants_attributes_4_representation_orders_attributes_1_maat_reference }
          let(:error) { 'foobar' }

          it_behaves_like 'message found',
                          long: 'Defendant 4 representation order 1 maat reference foobar',
                          short: 'Foobar',
                          api: 'Defendant 4 representation order 1 maat reference foobar'
        end
      end
    end

    context 'with nested attribute errors' do
      context 'with has_many sub-model translations' do
        context 'when key and error exist' do
          let(:key) { 'defendant.first_name' }
          let(:error) { 'blank' }

          it_behaves_like 'message found',
                          long: 'Enter a first name for the first defendant',
                          short: 'Cannot be blank',
                          api: 'The first name for the first defendant must not be blank'
        end
      end

      context 'with has_many sub-sub-model translations' do
        context 'with . format' do
          let(:key) { 'defendant.representation_order.maat_reference' }
          let(:error) { 'blank' }

          it_behaves_like 'message found',
                          long: 'Enter a valid MAAT reference for the first representation order of the first defendant',
                          short: 'Invalid format',
                          api: 'Enter a valid MAAT reference for the first representation order of the first defendant'
        end

        context 'with . plus numbered format' do
          let(:key) { 'defendant.representation_order_1_maat_reference' }
          let(:error) { 'blank' }

          it_behaves_like 'message found',
                          long: 'Enter a valid MAAT reference for the first representation order of the first defendant',
                          short: 'Invalid format',
                          api: 'Enter a valid MAAT reference for the first representation order of the first defendant'
        end
      end
    end
  end
end
