RSpec.shared_examples 'returns CCLF Litigator Fee bill (sub)type' do |code|
  before { allow(fee_type).to receive(:unique_code).and_return code }

  it 'returns CCLF Litigator Fee bill (sub)type - LIT_FEE' do
    is_expected.to eql 'LIT_FEE'
  end
end

RSpec.shared_examples 'Litigator Fee Adapter' do |bill_scenario_mappings|
  let(:fee) { instance_double(Fee::BaseFee) }
  let(:claim) { instance_double(Claim::BaseClaim, case_type:) }
  let(:case_type) { instance_double(CaseType) }
  let(:fee_type) { instance_double(Fee::BaseFeeType) }

  before do
    allow(fee).to receive_messages(fee_type:, claim:)
  end

  describe '#bill_type' do
    bill_scenario_mappings.each_key do |code|
      context "with #{code} fee type" do
        subject { described_class.new(fee).bill_type }

        include_examples 'returns CCLF Litigator Fee bill (sub)type', code
      end
    end
  end

  describe '#bill_subtype' do
    bill_scenario_mappings.each_key do |code|
      context "with #{code} fee type" do
        subject { described_class.new(fee).bill_subtype }

        include_examples 'returns CCLF Litigator Fee bill (sub)type', code
      end
    end
  end
end
