# frozen_string_literal: true

RSpec.describe ErrorDetailCollection do
  let(:instance) { described_class.new }
  let(:ed2) { ErrorDetail.new(:first_name, 'You must specify a first name', 'Cannot be blank', 'You must specify a first name', 20) }
  let(:ed1) { ErrorDetail.new(:dob, 'Date of birth is invalid', 'Invalid date', 'Date of birth is invalid', 10) }
  let(:ed3) { ErrorDetail.new(:dob, 'Date of birth too far in the past', 'Too old', 'Date of birth too far in the past', 30) }

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
        expect(instance[:key1]).to match_array(['value 1', 'value 2'])
      end
    end
  end

  describe '#short_messages_for' do
    subject { instance.short_messages_for(:dob) }

    context 'with one short_message per key' do
      before { instance[:dob] = ed1 }

      it 'returns the short message for the named key' do
        is_expected.to eq 'Invalid date'
      end
    end

    context 'with multiple short messages per key' do
      before do
        instance[:dob] = ed1
        instance[:dob] = ed3
      end

      it { is_expected.to eq 'Invalid date, Too old' }
    end
  end

  describe '#header_errors' do
    subject(:header_errors) { instance.header_errors }

    before do
      instance[:first_name] = ed2
      instance[:dob] = ed1
      instance[:dob] = ed3
    end

    it { is_expected.to all(be_instance_of(ErrorDetail)) }
    it { is_expected.to have(3).items }

    it 'sorts the array by sequence values' do
      expect(header_errors.map(&:sequence)).to eq [10, 20, 30]
    end
  end

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
