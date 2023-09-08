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

        attr_accessor :my_numeric_attribute, :relation

        delegate :nested_relation, to: :relation
      end
    end

    context 'with simple attribute validation' do
      let(:rule) do
        Rule::Struct.new(:my_numeric_attribute, :equal, 100, message: 'must be exactly 100')
      end

      context 'when rule is met' do
        let(:object) { test_class.new(my_numeric_attribute: 100) }

        it { is_expected.to be_truthy }

        it 'does not add error to object attribute' do
          met
          expect(object.errors['my_numeric_attribute']).to be_empty
        end
      end

      context 'when rule is not met' do
        let(:object) { test_class.new(my_numeric_attribute: 101) }

        it { is_expected.to be_falsey }

        it {
          met
          expect(object.errors['my_numeric_attribute']).to include('must be exactly 100')
        }
      end

      context 'when rule is not met without error message specified' do
        let(:rule) { Rule::Struct.new(:my_numeric_attribute, :equal, 100) }
        let(:object) { test_class.new(my_numeric_attribute: 101) }

        it {
          met
          expect(object.errors['my_numeric_attribute']).to include('my_numeric_attribute is invalid')
        }
      end

      context 'when attribute value is nil' do
        let(:object) { test_class.new(my_numeric_attribute: nil) }

        it { is_expected.to be_falsey }

        it {
          met
          expect(object.errors['my_numeric_attribute']).to include('must be exactly 100')
        }
      end

      context 'when object does not respond to attribute' do
        let(:object) { test_class.new }
        let(:rule) do
          Rule::Struct.new(:non_existent_attribute, :equal, 100, message: 'must be exactly 100')
        end

        it { expect { met }.to raise_error NoMethodError }
      end
    end

    shared_examples 'with nested relation attribute' do |attribute_under_test|
      context "with nested relation attribute validation using a #{attribute_under_test.class}" do
        let(:rule) do
          Rule::Struct.new(attribute_under_test,
                           :inclusion,
                           [1, 2],
                           message: 'nested relation id must be included in...')
        end
        let(:object) { test_class.new(relation:) }
        let(:relation) { double('Relation', nested_relation:) }
        let(:nested_relation) { double('NestedRelation', id: 990) }

        context 'when rule is met' do
          let(:nested_relation) { double('NestedRelation', id: 1) }

          it { is_expected.to be_truthy }

          it 'does not add error to nested method chain' do
            met
            expect(object.errors['relation.nested_relation.id']).to be_empty
          end
        end

        context 'when rule is not met' do
          let(:nested_relation) { double('NestedRelation', id: 3) }

          it { is_expected.to be_falsey }

          it 'adds error to nested method chain' do
            met
            expect(object.errors['relation.nested_relation.id']).to include('nested relation id must be included in...')
          end

          context 'with attribute_for_error option specified' do
            let(:rule) do
              Rule::Struct.new(%i[relation nested_relation id],
                               :inclusion,
                               [1, 2],
                               message: 'nested relation id must be included in...',
                               attribute_for_error: :my_other_field)
            end

            it { is_expected.to be_falsey }

            it 'adds error to specified attribute of object' do
              met
              expect(object.errors['my_other_field']).to include('nested relation id must be included in...')
            end
          end
        end

        context 'when nested object method chain returns nil' do
          let(:relation) { double('Relation', nested_relation: nil) }

          it { is_expected.to be_falsey }

          it 'adds error to nested method chain' do
            met
            expect(object.errors['relation.nested_relation.id']).to include('nested relation id must be included in...')
          end
        end

        context 'when nested object method chain contains undefined method' do
          before { allow(relation).to receive(:nested_relation).and_raise NoMethodError }

          it {
            expect { met }.to raise_error NoMethodError
          }
        end
      end
    end

    include_examples 'with nested relation attribute', %i[relation nested_relation id]
    include_examples 'with nested relation attribute', 'relation.nested_relation.id'
  end
end
