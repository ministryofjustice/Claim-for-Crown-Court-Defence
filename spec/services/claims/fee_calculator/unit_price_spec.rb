RSpec.configure do |c|
  c.alias_it_behaves_like_to :it_returns, 'returns'
end

RSpec.shared_examples 'a successful fee calculator response' do
  it 'returns success? true' do
    expect(response.success?).to be true
  end

  it 'includes amount' do
    expect(response.data.amount).to be_kind_of Float
  end

  it 'includes no errors' do
    expect(response.errors).to be_nil
  end

  it 'includes no error message' do
    expect(response.message).to be_nil
  end
end

RSpec.shared_examples 'a failed fee calculator response' do
  it 'includes success? false' do
    expect(response.success?).to be false
  end

  it 'includes no data' do
    expect(response.data).to be_nil
  end

  it 'includes errors' do
    expect(response.errors).to be_an Array
  end

  it 'includes error message' do
    expect(response.message).to be_a String
  end
end

RSpec.shared_examples 'a fee calculator response with amount' do |options|
  let(:expected_amount) { options.fetch(:amount, nil) }

  it 'includes non-zero amount' do
    expect(response.data.amount).to be > 0
  end

  # TODO: maybe too much integration??
  if options&.fetch(:amount)
    it 'includes expected amount' do
      expect(response.data.amount).to be expected_amount
    end
  end
end

RSpec.describe Claims::FeeCalculator::UnitPrice, :fee_calc_vcr do
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

  describe '#call' do
    subject(:response) { described_class.new(claim, params).call }

    context 'for a fixed fee' do
      it_returns 'a successful fee calculator response'
      it_returns 'a fee calculator response with amount', amount: 130.0
    end

    context 'for a fixed fee case uplift' do
      let(:uplift_fee) { create(:fixed_fee, :fxacu_fee, claim: claim, quantity: 1) }

      before do
        params.merge!(fee_type_id: uplift_fee.fee_type.id)
        params[:fees].merge!("1": { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
      end

      it_returns 'a successful fee calculator response'
      it_returns 'a fee calculator response with amount', amount: 26.0
    end

    context 'for a fixed fee number of cases uplift' do
      let(:uplift_fee) { create(:fixed_fee, :fxnoc_fee, claim: claim, quantity: 1) }

      before do
        params.merge!(fee_type_id: uplift_fee.fee_type.id)
        params[:fees].merge!("1": { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
      end

      it_returns 'a successful fee calculator response'
      it_returns 'a fee calculator response with amount', amount: 26.0
    end

    context 'for a fixed fee number of defendants uplift' do
      let(:uplift_fee) { create(:fixed_fee, :fxndr_fee, claim: claim, quantity: 1) }

      before do
        params.merge!(fee_type_id: uplift_fee.fee_type.id)
        params[:fees].merge!("1": { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
      end

      it_returns 'a successful fee calculator response'
      it_returns 'a fee calculator response with amount', amount: 26.0
    end

    context 'for erroneous request' do
      before { params.merge!(advocate_category: 'Not an advocate category') }

      it_returns 'a failed fee calculator response'
    end
  end
end
