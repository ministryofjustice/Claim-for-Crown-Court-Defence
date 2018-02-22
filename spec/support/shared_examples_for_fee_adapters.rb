shared_examples_for 'a mapping fee adapter' do
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

shared_examples_for 'a simple bill adapter' do
  subject { described_class.new(instance_double('fee')) }

  it { is_expected.to respond_to(:bill_type) }
  it { is_expected.to respond_to(:bill_subtype) }

  it 'should respond to .acts_as_simple_bill' do
    expect(described_class).to respond_to :acts_as_simple_bill
  end
end
