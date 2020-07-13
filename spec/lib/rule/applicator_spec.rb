# frozen_string_literal: true

RSpec.describe Rule::Applicator, type: :rule do
  subject { described_class.new('object', 'rule') }

  it { is_expected.to respond_to(:object, :rule) }

  describe '#met?' do
    subject(:met) { instance.met? }

    let(:instance) { described_class.new(object, rule) }
    let(:test_class) do
      Class.new do
        include ActiveModel::Model

        attr_accessor :my_numeric_attribute
      end
    end

    let(:rule) do
      Rule::Struct.new(:my_numeric_attribute, :equal, 100, 'must be exactly 100')
    end

    context 'when rule is met' do
      let(:object) { test_class.new(my_numeric_attribute: 100) }

      it { is_expected.to be_truthy }

      it 'does not add error to object' do
        met
        expect(object.errors['my_numeric_attribute']).to be_empty
      end
    end

    context 'when rule is not met' do
      let(:object) { test_class.new(my_numeric_attribute: 101) }

      it { is_expected.to be_falsey }

      it 'adds error to object' do
        met
        expect(object.errors['my_numeric_attribute']).to include('must be exactly 100')
      end
    end
  end
end
