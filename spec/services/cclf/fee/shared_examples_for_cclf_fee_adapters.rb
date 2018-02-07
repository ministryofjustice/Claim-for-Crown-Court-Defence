shared_examples 'returns CCLF Litigator Fee bill (sub)type' do |code|
  before { allow(fee_type).to receive(:unique_code).and_return code }
  it 'returns CCLF Litigator Fee bill (sub)type - LIT_FEE' do
    is_expected.to eql 'LIT_FEE'
  end
end

shared_examples 'Litigator Fee Adapter' do |bill_scenario_mappings|
  let(:fee) { instance_double('fee') }
  let(:claim) { instance_double('claim', case_type: case_type) }
  let(:case_type) { instance_double(::CaseType) }
  let(:fee_type) { instance_double('fee_type') }

  before do
    allow(fee).to receive(:fee_type).and_return fee_type
    allow(fee).to receive(:claim).and_return claim
  end

  describe '#bill_type' do
    bill_scenario_mappings.keys.each do |code|
      context "for #{code} fee type" do
        subject { described_class.new(fee).bill_type }
        include_examples 'returns CCLF Litigator Fee bill (sub)type', code
      end
    end
  end

  describe '#bill_subtype' do
    bill_scenario_mappings.keys.each do |code|
      context "for #{code} fee type" do
        subject { described_class.new(fee).bill_subtype }
        include_examples 'returns CCLF Litigator Fee bill (sub)type', code
      end
    end
  end

  describe '#vat_included' do
    bill_scenario_mappings.keys.each do |code|
      context "for #{code} fee type" do
        subject { described_class.new(fee).vat_included }
        it { is_expected.to be_falsey }
      end
    end
  end
end
