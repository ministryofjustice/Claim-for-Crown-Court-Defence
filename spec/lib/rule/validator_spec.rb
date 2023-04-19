# frozen_string_literal: true

RSpec.describe Rule::Validator, type: :rule do
  let(:test_class) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :quantity, :amount
    end
  end

  describe '#met?' do
    let(:object_with_quantity_and_amount_rules) { test_class.new() }
    let(:object_with_amount_rule) { test_class.new() }

    let(:rule_sets) do
      set1 = Rule::Set.new(object_with_quantity_and_amount_rules)
      set1 << Rule::Struct.new(:quantity, :equal, 1, message: 'quantity_numericality')
      set1 << Rule::Struct.new(:amount, :maximum, 1000, message: 'amount_maximum')
      set2 = Rule::Set.new(object_with_amount_rule)
      set2 << Rule::Struct.new(:amount, :minimum, 10, message: 'amount_minimum')
      [
        set1,
        set2
      ]
    end

    context 'with one rule set' do
      subject(:validate) { described_class.new(object, rule_set_1).met? }

      let(:rule_set_1) { rule_sets.select { |set| set.object == object_with_quantity_and_amount_rules } }

      context 'when no rules violated' do
        let(:object) { test_class.new(quantity: 1, amount: 1000) }

        it { expect(validate).to be_truthy }
        it { expect { validate }.not_to change { object.errors.count } }
      end

      context 'when one rule violated' do
        let(:object) { test_class.new(quantity: 1, amount: 1001) }

        it { expect(validate).to be_falsey }
        it { expect { validate }.to change { object.errors.count }.by(1) }
      end

      context 'when more than one rule violated' do
        let(:object) { test_class.new(quantity: 2, amount: 1001) }

        it { expect(validate).to be_falsey }
        it { expect { validate }.to change { object.errors.count }.by(2) }
      end
    end

    context 'with more than one rule set' do
      subject(:validate) { described_class.new(object, rule_sets).met? }

      context 'when no rule sets rule violated' do
        let(:object) { test_class.new(quantity: 1, amount: 1000) }

        it { expect(validate).to be_truthy }
        it { expect { validate }.not_to change { object.errors.count } }
      end

      context 'when second rule sets rule violated' do
        let(:object) { test_class.new(quantity: 1, amount: 9) }

        it { expect(validate).to be_falsey }
        it { expect { validate }.to change { object.errors.count }.by(1) }
      end
    end
  end

  describe '#validate' do
    let(:instance) { described_class.new('object', 'rule_set') }

    it 'is alias for met?' do
      expect(instance.method(:validate)).to eq(instance.method(:met?))
    end
  end
end
