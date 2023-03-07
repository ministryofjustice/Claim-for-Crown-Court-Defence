# frozen_string_literal: true

RSpec.describe Rule::Set, type: :rule do
  subject(:set) { described_class.new(object) }

  let(:test_class) { Class.new { attr_accessor :id } }
  let(:object) { test_class.new }

  it { is_expected.to respond_to(:object) }

  it 'identified by an object' do
    expect(set.object).to be_a(test_class)
  end

  describe '#<<' do
    subject(:append) { set << 'my rule' }

    it 'appends to rules' do
      expect { append }.to change(set, :count).by(1)
    end
  end

  describe '#each' do
    before do
      set << 'rule 1'
      set << 'rule 2'
    end

    it 'enumerates rules' do
      expect { |b| set.each(&b) }.to yield_successive_args('rule 1', 'rule 2')
    end
  end

  context 'when using to store rules for multiple objects' do
    let(:object1) { test_class.new.tap { |o| o.id = 1 } }
    let(:object2) { test_class.new.tap { |o| o.id = 2 } }
    let(:set1) { described_class.new(object1) }
    let(:set2) { described_class.new(object2) }

    let(:sets) do
      set1 << 'rule 1a'
      set1 << 'rule 1b'
      set2 << 'rule 2a'
      set2 << 'rule 2b'
      [set1, set2]
    end

    context 'when searching by specific object id' do
      subject(:subsets) { sets.select { |set| set.object.id.eql?(1) } }

      it { is_expected.to all(be_a(described_class)) }

      it 'returns appicable sets' do
        expect(subsets.flat_map(&:to_a)).to contain_exactly('rule 1a', 'rule 1b')
      end
    end
  end
end
