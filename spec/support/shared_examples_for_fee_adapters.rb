RSpec.shared_examples_for 'a mapping fee adapter' do
  describe '#call' do
    it { is_expected.to be_instance_of described_class }
    it { is_expected.to respond_to :bill_type }
    it { is_expected.to respond_to :bill_subtype }
    it { is_expected.to respond_to :object }
    it { is_expected.to respond_to :mappings }
  end

  describe '#mappings' do
    subject {described_class.new.mappings }

    it { is_expected.to be_a Hash }

    it 'each key\'s value is a Hash' do
      expect(subject.values.first).to be_a Hash
    end

    it 'each key\'s value includes bill type and subtype details' do
      expect(subject.values.first.keys).to include(:bill_type, :bill_subtype)
    end
  end
end

RSpec.shared_examples_for 'a simple bill adapter' do |options|
  subject { described_class.new(instance_double('fee')) }

  it { is_expected.to respond_to(:bill_type) }
  it { is_expected.to respond_to(:bill_subtype) }

  it 'should respond to .acts_as_simple_bill' do
    expect(described_class).to respond_to :acts_as_simple_bill
  end

  describe '#bill_type' do
    subject { described_class.new(fee).bill_type }
    it "returns expected bill type - #{options[:bill_type]}" do
      is_expected.to eql options[:bill_type]
    end
  end

  describe '#bill_subtype' do
    subject { described_class.new(fee).bill_subtype }
    it "returns expected bill type - #{options[:bill_subtype]}" do
      is_expected.to eql options[:bill_subtype]
    end
  end
end

RSpec.shared_examples 'a bill types delegator' do |adapter_klass|
  let(:adapter) { instance_double(adapter_klass) }

  it "delegates bill types to #{adapter_klass} " do
    expect(adapter_klass).to receive(:new).with(bill).and_return(adapter)
    expect(adapter).to receive(:bill_type)
    expect(adapter).to receive(:bill_subtype)
    subject
  end
end
