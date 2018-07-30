RSpec.describe Claims::FeeCalculator::UnitPrice, :vcr do
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

  describe '#call' do
    subject(:response) { described_class.new(claim, params).call }

    # create params from fees on claim for brevity/dryness
    before do
      claim.fixed_fees.each_with_index do |fee, idx|
        params[:fees].merge!("#{idx}": { fee_type_id: fee.fee_type.id, quantity: fee.quantity })
      end
    end

    context 'for a fixed fee' do
      it_behaves_like 'successful fee calculator response'

      include_examples 'fee calculator amount', amount: 130.0
    end

    context 'for a fixed fee case uplift' do
      let(:uplift_fee) { create(:fixed_fee, :fxacu_fee, claim: claim, quantity: 1) }

      before { params.merge!(fee_type_id: uplift_fee.id) }

      it_behaves_like 'successful fee calculator response'

      include_examples 'fee calculator amount', amount: 26.0
    end

    context 'for a fixed fee number of cases uplift' do
      let(:uplift_fee) { create(:fixed_fee, :fxnoc_fee, claim: claim, quantity: 1) }

      before { params.merge!(fee_type_id: uplift_fee.id) }

      it_behaves_like 'successful fee calculator response'

      include_examples 'fee calculator amount', amount: 26.0
    end

    context 'for a fixed fee number of defendants uplift' do
      let(:uplift_fee) { create(:fixed_fee, :fxndr_fee, claim: claim, quantity: 1) }

      before { params.merge!(fee_type_id: uplift_fee.id) }

      it_behaves_like 'successful fee calculator response'

      include_examples 'fee calculator amount', amount: 26.0
    end

    context 'for erroneous request' do
      before { params.merge!(advocate_category: 'Not an advocate category') }

      it_behaves_like 'failed fee calculator response'
    end
  end
end