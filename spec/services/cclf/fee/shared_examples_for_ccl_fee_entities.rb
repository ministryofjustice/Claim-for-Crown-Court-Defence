shared_examples 'returns CCLF Litigator Fee bill type' do |code|
  before { allow(fee_type).to receive(:unique_code).and_return code }
  it 'rreturns CCLF Litigator Fee bill type' do
    is_expected.to eql 'LIT_FEE'
  end
end

shared_examples 'CCLF Litigator Fee entity' do |bill_scenario_mappings|
  let(:claim) { instance_double('claim') }
  let(:fee) { instance_double('fee') }

  before do
    allow(fee).to receive(:fee_type).and_return fee_type
  end

  describe '#bill_type' do
    bill_scenario_mappings.keys.each do |code|
      context "for #{code} fee type" do
        subject { described_class.new(fee).bill_type }
        include_examples 'returns CCLF Litigator Fee bill type', code
      end
    end
  end

  describe '#bill_subtype' do
    bill_scenario_mappings.keys.each do |code|
      context "for #{code} fee type" do
        subject { described_class.new(fee).bill_subtype }
        include_examples 'returns CCLF Litigator Fee bill type', code
      end
    end
  end

  describe '#bill_scenario' do
    bill_scenario_mappings.each do |code, scenario|
      context "for #{code} fee type" do
        subject { described_class.new(fee).bill_scenario }

        before { allow(fee_type).to receive(:unique_code).and_return code }

        it "returns CCLF Litigator Fee scenario #{scenario}" do
          is_expected.to eql scenario
        end
      end
    end
  end

  describe '#claimed?' do
    subject { described_class.new(fee).claimed? }

    context 'when fee amount is positive' do
      let(:fee) { instance_double('fee', amount: 0.01) }
      it 'returns true' do
        is_expected.to be_truthy
      end
    end

    context 'when fee amount is nil' do
      let(:fee) { instance_double('fee', amount: nil) }
      it 'returns false' do
        is_expected.to be_falsey
      end
    end

    context 'when fee amount is 0' do
      let(:fee) { instance_double('fee', amount: nil) }
      it 'returns false' do
        is_expected.to be_falsey
      end
    end
  end
end
