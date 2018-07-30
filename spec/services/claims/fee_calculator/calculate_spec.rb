RSpec.describe Claims::FeeCalculator::Calculate, :vcr do
  subject { described_class.new(claim, params) }

  let(:case_type) { create(:case_type, :appeal_against_conviction) }
  let(:claim) { create(:draft_claim, case_type: case_type) }
  let(:fee) { create(:fixed_fee, :fxacv_fee, claim: claim, quantity: 1) }

  let(:params) do
    {
      format: :json,
      id: claim.id,
      advocate_category: 'Junior alone',
      fee_type_id: fee.fee_type.id,
      fees: {
        "0": { fee_type_id: fee.fee_type.id, quantity: fee.quantity }
      }
    }
  end

  it { is_expected.to respond_to(:call) }
  it { is_expected.to delegate_method(:earliest_representation_order_date).to(:claim) }
  it { is_expected.to delegate_method(:agfs?).to(:claim) }
  it { is_expected.to delegate_method(:case_type).to(:claim) }
  it { is_expected.to delegate_method(:offence).to(:claim) }

  it { is_expected.to respond_to(:claim) }
  it { is_expected.to respond_to(:options) }
  it { is_expected.to respond_to(:fee_type) }
  it { is_expected.to respond_to(:advocate_category) }
  it { is_expected.to respond_to(:quantity) }
  it { is_expected.to respond_to(:current_page_fees) }

  describe '#call' do
    subject(:response) { described_class.new(claim, params).call }

    it 'returns a response object' do
      is_expected.to be_a Claims::FeeCalculator::Response
    end

    context 'response object' do
      it { is_expected.to respond_to(:success?) }
      it { is_expected.to respond_to(:data) }
      it { is_expected.to respond_to(:errors) }
      it { is_expected.to respond_to(:message) }
    end
  end
end