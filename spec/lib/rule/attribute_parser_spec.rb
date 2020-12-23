# frozen_string_literal: true

RSpec.describe Rule::AttributeParser, type: :rule do
  describe '#call' do
    subject { described_class.new(attribute).call }

    context 'with a symbol' do
      let(:attribute) { :my_field }

      it { is_expected.to eql [:my_field] }
    end

    context 'with an array of symbols' do
      let(:attribute) { %i[object nested_object id] }

      it { is_expected.to eql %i[object nested_object id] }
    end

    context 'with an array of strings' do
      let(:attribute) { %w[object nested_object id] }

      it { is_expected.to eql %i[object nested_object id] }
    end

    context 'with a string' do
      context 'with no dot notation' do
        let(:attribute) { 'my_field' }

        it { is_expected.to eql %i[my_field] }
      end

      context 'with dot notation' do
        let(:attribute) { 'object.nested_object.id' }

        it { is_expected.to eql %i[object nested_object id] }
      end
    end
  end
end
