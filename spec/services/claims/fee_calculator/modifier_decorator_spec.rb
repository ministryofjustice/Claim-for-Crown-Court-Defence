RSpec.shared_examples 'equality' do |method|
  subject { described_class.new(modifier).send(method, other_modifier) }
  let(:decorated_modifier) { described_class.new(modifier) }

  context 'when called with arg that is not of the same class' do
    let(:modifier) { OpenStruct.new(limit_from: 0, modifier_type: OpenStruct.new(name: 'RETRIAL_INTERVAL')) }

    context 'with same name and limit_from attributes' do
      let(:other_modifier) { OpenStruct.new(name: :retrial_interval, limit_from: 0) }
      it { is_expected.to be_truthy }
    end

    context 'with different name attribute' do
      let(:other_modifier) { OpenStruct.new(name: :different_name, limit_from: 0) }
      it { is_expected.to be_falsey }
    end

    context 'with different limit_from attribute' do
      let(:other_modifier) { OpenStruct.new(name: :retrial_interval, limit_from: 1) }
      it { is_expected.to be_falsey }
    end
  end

  context 'when called with arg of same class of object' do
    let(:other_decorated_modifier) { described_class.new(OpenStruct.new(fixed_percent: '-20.00', percent_per_unit: '0.00')) }
    it 'calls super' do
      expect(decorated_modifier.send(method, decorated_modifier)).to eql true
      expect(decorated_modifier.send(method, other_decorated_modifier)).to eql false
    end
  end

  context 'with decorator as arg' do
    context 'with same name and limit_from attributes' do
      let(:other_modifier) { OpenStruct.new(name: :retrial_interval, limit_from: 0) }
      it { expect(other_modifier.send(method, decorated_modifier)).to be_falsey }
    end
  end
end

RSpec.describe Claims::FeeCalculator::ModifierDecorator do
  subject { described_class.new(modifier) }
  let(:modifier) { OpenStruct.new(fixed_percent: '-30.00', percent_per_unit: '0.00') }

  it { is_expected.to respond_to(:fixed_percent?) }
  it { is_expected.to respond_to(:scale_factor) }

  context 'delegates' do
    specify '#fixed_percent' do
      expect(modifier).to receive(:fixed_percent)
      subject.fixed_percent
    end

    specify '#percent_per_unit' do
      expect(modifier).to receive(:percent_per_unit)
      subject.percent_per_unit
    end
  end

  describe '#scale_factor' do
    subject { described_class.new(modifier).scale_factor }

    let(:modifier) { OpenStruct.new(fixed_percent: '-30.00', percent_per_unit: '0.00') }
    context 'when value is negative percentage (-30.00)' do
      it { is_expected.to eql 0.7 }
    end

    context 'when value is positive percentage (20.00)' do
      let(:modifier) { OpenStruct.new(fixed_percent: '0.00', percent_per_unit: '20.00') }
      it { is_expected.to eql 0.2 }
    end
  end

  describe '#fixed_percent?' do
    subject { described_class.new(modifier).fixed_percent? }

    context 'when fixed_percent is negative' do
      let(:modifier) { OpenStruct.new(fixed_percent: '-30.00', percent_per_unit: '0.00') }
      it { is_expected.to be_truthy }
    end

    context 'when fixed_percent is positive' do
      let(:modifier) { OpenStruct.new(fixed_percent: '30.00', percent_per_unit: '0.00') }
      it { is_expected.to be_truthy }
    end

    context 'when fixed_percent is zero' do
      let(:modifier) { OpenStruct.new(fixed_percent: '0.00', percent_per_unit: '20.00') }
      it { is_expected.to be_falsey }
    end
  end

  describe '#==' do
    include_examples 'equality', :==
  end

  describe '#eql?' do
    include_examples 'equality', :eql?
  end
end
