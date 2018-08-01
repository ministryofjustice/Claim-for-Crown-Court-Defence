RSpec.describe Claims::FeeCalculator::Calculate, :fee_calc_vcr do
  subject { described_class.new(claim, params) }

  # IMPORTANT: use specific case type, offence class, fee types and reporder
  # date in order to reduce and afix VCR cassettes required (that have to match
  # on query values), prevent flickering specs (from random offence classes,
  # rep order dates) and to allow testing actual amounts "calculated".
  let(:claim) do
    create(:draft_claim,
      create_defendant_and_rep_order: false,
      create_defendant_and_rep_order_for_scheme_9: true,
      case_type: case_type, offence: offence
    )
  end
  let(:case_type) { create(:case_type, :appeal_against_conviction) }
  let(:offence_class) { create(:offence_class, class_letter: 'K') }
  let(:offence) { create(:offence, offence_class: offence_class) }
  let(:fee_type) { create(:fixed_fee_type, :fxacv) }
  let(:fee) { create(:fixed_fee, fee_type: fee_type, claim: claim, quantity: 1) }

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