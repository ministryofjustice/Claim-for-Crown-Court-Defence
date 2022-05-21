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
    subject(:message) { translator.message(error) }

    context 'with unnested translations' do
      context 'when key and error exists' do
        let(:error) { instance_double(ActiveModel::Error, attribute: :name, message: 'cannot_be_blank') }

        it_behaves_like 'message found',
                        long: 'The claimant name must not be blank, please enter a name',
                        short: 'Enter a name',
                        api: 'The claimant name must not be blank'
      end

      context 'when key does not exist' do
        let(:error) { instance_double(ActiveModel::Error, attribute: :stepmother, message: 'too_long') }

        it_behaves_like 'message found',
                        long: 'Stepmother too long',
                        short: 'Too long',
                        api: 'Stepmother too long'
      end

      context 'when key exists but error does not exist' do
        let(:error) { instance_double(ActiveModel::Error, attribute: :name, message: 'rubbish') }

        it_behaves_like 'message found',
                        long: 'Name rubbish',
                        short: 'Rubbish',
                        api: 'Name rubbish'
      end
    end

    context 'with custom single nested errors' do
      context 'when key and error exist' do
        let(:error) { instance_double(ActiveModel::Error, attribute: :defendant_2_first_name, message: 'blank') }

        it_behaves_like 'message found',
                        long: 'Enter a first name for the second defendant',
                        short: 'Cannot be blank',
                        api: 'The first name for the second defendant must not be blank'
      end

      context 'when key for submodel does not exist in base model' do
        let(:error) { instance_double(ActiveModel::Error, attribute: :person_2_first_name, message: 'blank') }

        it_behaves_like 'message found',
                        long: 'Person 2 first name blank',
                        short: 'Blank',
                        api: 'Person 2 first name blank'
      end

      context 'when key for submodel exists but key for field in submodel does not' do
        let(:error) { instance_double(ActiveModel::Error, attribute: :defendant_2_age, message: 'blank') }

        it_behaves_like 'message found',
                        long: 'Defendant 2 age blank',
                        short: 'Blank',
                        api: 'Defendant 2 age blank'
      end

      context 'when key for submodel and field on submodel exists but error does not' do
        let(:error) { instance_double(ActiveModel::Error, attribute: :defendant_2_first_name, message: 'foo') }

        it_behaves_like 'message found',
                        long: 'Defendant 2 first name foo',
                        short: 'Foo',
                        api: 'Defendant 2 first name foo'
      end
    end

    context 'with custom sinlge nested error with .format' do
      context 'when nested key and error exists' do
        let(:error) { instance_double(ActiveModel::Error, attribute: 'fixed_fee.quantity', message: 'invalid') }

        it_behaves_like 'message found',
                        long: 'Enter a valid quantity for the first fixed fee',
                        short: 'Enter a valid quantity',
                        api: 'Enter a valid quantity for the first fixed fee'
      end
    end

    context 'with custom double level nested errors' do
      context 'when nested keys and errors exist' do
        let(:error) do
          instance_double(
            ActiveModel::Error,
            attribute: :defendant_5_representation_order_2_maat_reference,
            message: 'blank'
          )
        end

        it_behaves_like 'message found',
                        long: 'Enter a valid MAAT reference for the second representation order of the fifth defendant',
                        short: 'Invalid format',
                        api: 'Enter a valid MAAT reference for the second representation order of the fifth defendant'
      end

      context 'when key for sub-sub-model does not exist' do
        let(:error) do
          instance_double(ActiveModel::Error, attribute: :defendant_5_court_order_2_maat_reference, message: 'blank')
        end

        it_behaves_like 'message found',
                        long: 'Defendant 5 court order 2 maat reference blank',
                        short: 'Blank',
                        api: 'Defendant 5 court order 2 maat reference blank'
      end

      context 'when key for field on sub sub model does not exist' do
        let(:error) do
          instance_double(ActiveModel::Error, attribute: :defendant_5_representation_order_2_court, message: 'blank')
        end

        it_behaves_like 'message found',
                        long: 'Defendant 5 representation order 2 court blank',
                        short: 'Blank',
                        api: 'Defendant 5 representation order 2 court blank'
      end

      context 'when key for error on sub sub model does not exist' do
        let(:error) do
          instance_double(
            ActiveModel::Error,
            attribute: :defendant_5_representation_order_2_maat_reference,
            message: 'no_such_error'
          )
        end

        it_behaves_like 'message found',
                        long: 'Defendant 5 representation order 2 maat reference no such error',
                        short: 'No such error',
                        api: 'Defendant 5 representation order 2 maat reference no such error'
      end
    end

    context 'with rails single level nested errors' do
      context 'when key and error exist' do
        let(:error) do
          instance_double(ActiveModel::Error, attribute: 'defendants_attributes_0_first_name', message: 'blank')
        end

        it_behaves_like 'message found',
                        long: 'Enter a first name for the first defendant',
                        short: 'Cannot be blank',
                        api: 'The first name for the first defendant must not be blank'
      end

      context 'when key for submodel does not exist in base model' do
        let(:error) { instance_double(ActiveModel::Error, attribute: 'foos_attributes_0_age', message: 'blank') }

        it_behaves_like 'message found',
                        long: 'Foo 1 age blank',
                        short: 'Blank',
                        api: 'Foo 1 age blank'
      end

      context 'when key for submodel exists but key for attribute on submodel does not' do
        let(:error) { instance_double(ActiveModel::Error, attribute: 'defendants_attributes_0_age', message: 'blank') }

        it_behaves_like 'message found',
                        long: 'Defendant 1 age blank',
                        short: 'Blank',
                        api: 'Defendant 1 age blank'
      end

      context 'when key for submodel and attribute on submodel exists but error does not' do
        let(:error) do
          instance_double(ActiveModel::Error, attribute: 'defendants_attributes_0_first_name', message: 'bar')
        end

        it_behaves_like 'message found',
                        long: 'Defendant 1 first name bar',
                        short: 'Bar',
                        api: 'Defendant 1 first name bar'
      end
    end

    context 'with rails double level nested errors' do
      context 'when nested keys and errors exist' do
        let(:error) do
          instance_double(
            ActiveModel::Error,
            attribute: :defendants_attributes_4_representation_orders_attributes_1_maat_reference,
            message: 'blank'
          )
        end

        it_behaves_like 'message found',
                        long: 'Enter a valid MAAT reference for the second representation order of the fifth defendant',
                        short: 'Invalid format',
                        api: 'Enter a valid MAAT reference for the second representation order of the fifth defendant'
      end

      context 'when key for sub-sub-model does not exist' do
        let(:error) do
          instance_double(
            ActiveModel::Error,
            attribute: :defendants_attributes_4_foobars_attributes_1_maat_reference,
            message: 'blank'
          )
        end

        it_behaves_like 'message found',
                        long: 'Defendant 4 foobar 1 maat reference blank',
                        short: 'Blank',
                        api: 'Defendant 4 foobar 1 maat reference blank'
      end

      context 'when key for attribute on sub-sub-model does not exist' do
        let(:error) do
          instance_double(
            ActiveModel::Error,
            attribute: :defendants_attributes_4_representation_orders_attributes_1_foobar,
            message: 'blank'
          )
        end

        it_behaves_like 'message found',
                        long: 'Defendant 4 representation order 1 foobar blank',
                        short: 'Blank',
                        api: 'Defendant 4 representation order 1 foobar blank'
      end

      context 'when key for error on sub-sub-model does not exist' do
        let(:error) do
          instance_double(
            ActiveModel::Error,
            attribute: :defendants_attributes_4_representation_orders_attributes_1_maat_reference,
            message: 'foobar'
          )
        end

        it_behaves_like 'message found',
                        long: 'Defendant 4 representation order 1 maat reference foobar',
                        short: 'Foobar',
                        api: 'Defendant 4 representation order 1 maat reference foobar'
      end
    end

    context 'with nested attribute single level errors with .format' do
      context 'when key and error exists' do
        let(:error) { instance_double(ActiveModel::Error, attribute: 'fixed_fee.quantity', message: 'invalid') }

        it_behaves_like 'message found',
                        long: 'Enter a valid quantity for the first fixed fee',
                        short: 'Enter a valid quantity',
                        api: 'Enter a valid quantity for the first fixed fee'
      end

      context 'when key does not exist' do
        let(:error) { instance_double(ActiveModel::Error, attribute: 'foo.bar', message: 'invalid') }

        it_behaves_like 'message found',
                        long: 'Foo 1 bar invalid',
                        short: 'Invalid',
                        api: 'Foo 1 bar invalid'
      end
    end

    context 'with nested attribute double level errors with . format' do
      context 'when key and error exists' do
        let(:error) do
          instance_double(
            ActiveModel::Error,
            attribute: 'defendant.representation_order.maat_reference',
            message: 'blank'
          )
        end

        it_behaves_like 'message found',
                        long: 'Enter a valid MAAT reference for the first representation order of the first defendant',
                        short: 'Invalid format',
                        api: 'Enter a valid MAAT reference for the first representation order of the first defendant'
      end

      context 'when key does not exist' do
        let(:error) do
          instance_double(ActiveModel::Error, attribute: 'defendant.court_order.maat_reference', message: 'invalid')
        end

        it_behaves_like 'message found',
                        long: 'Defendant 1 court order 1 maat reference invalid',
                        short: 'Invalid',
                        api: 'Defendant 1 court order 1 maat reference invalid'
      end
    end

    context 'with nested attribute double level errors with . plus numbered format' do
      let(:error) do
        instance_double(
          ActiveModel::Error,
          attribute: 'defendant.representation_order_1_maat_reference',
          message: 'blank'
        )
      end

      it_behaves_like 'message found',
                      long: 'Enter a valid MAAT reference for the first representation order of the first defendant',
                      short: 'Invalid format',
                      api: 'Enter a valid MAAT reference for the first representation order of the first defendant'
    end
  end
end
