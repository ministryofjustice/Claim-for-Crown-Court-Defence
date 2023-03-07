# frozen_string_literal: true

RSpec.describe ErrorMessage::DetailCollection do
  let(:instance) { described_class.new }

  let(:ed2) do
    ErrorMessage::Detail.new(:first_name,
                             'You must specify a first name',
                             'Cannot be blank',
                             'You must specify a first name',
                             20)
  end

  let(:ed1) do
    ErrorMessage::Detail.new(:dob,
                             'Enter a valid date of birth',
                             'Invalid date',
                             'Enter a valid date of birth',
                             10)
  end

  let(:ed3) do
    ErrorMessage::Detail.new(:dob,
                             'Check the date of birth',
                             'Too old',
                             'Check the date of birth',
                             30)
  end

  describe '#[]=' do
    context 'when assigning a single value to a key' do
      before { instance[:key1] = 'value for key 1' }

      it 'makes an array containing the single element' do
        expect(instance[:key1]).to eq(['value for key 1'])
      end
    end

    context 'when assigning multiple values to a key' do
      before do
        instance[:key1] = 'value 1'
        instance[:key1] = 'value 2'
      end

      it 'makes an array of all the elements assigned' do
        expect(instance[:key1]).to contain_exactly('value 1', 'value 2')
      end
    end
  end

  describe '#errors_for?' do
    subject { instance.errors_for?(fieldname) }

    context 'when fieldname key exists in collection' do
      let(:fieldname) { :foo }

      before { instance[:foo] = 'bar' }

      it { is_expected.to be_truthy }
    end

    context 'when fieldname key does not exist in collection' do
      let(:fieldname) { :foo }

      it { is_expected.to be_falsey }
    end
  end

  # see integration tests in presenter spec for:
  #
  # - describe '#short_messages_for' --> field_errors_for
  # - describe '#formatted_error_messages'
  # - describe '#summary_errors'

  describe '#size' do
    subject { instance.size }

    context 'with empty collection' do
      it { is_expected.to eq 0 }
    end

    context 'with multiple fieldnames with one error each' do
      before do
        instance[:first_name] = ed1
        instance[:dob] = ed2
      end

      it { is_expected.to eq 2 }
    end

    context 'with multiple errors on one fieldname' do
      before do
        instance[:dob] = ed1
        instance[:dob] = ed3
      end

      it { expect(instance.size).to eq 2 }
    end
  end
end
