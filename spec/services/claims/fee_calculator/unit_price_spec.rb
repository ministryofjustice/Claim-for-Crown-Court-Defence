RSpec.describe Claims::FeeCalculator::UnitPrice, :fee_calc_vcr do
  subject { described_class.new(claim, {}) }

  # IMPORTANT: use specific case type, offence class, fee types and reporder
  # date in order to reduce and afix VCR cassettes required (that have to match
  # on query values), prevent flickering specs (from random offence classes,
  # rep order dates) and to allow testing actual amounts "calculated".
  let(:claim) { build(:draft_claim) }
  let(:case_type) { create(:case_type, :appeal_against_conviction) }
  let(:offence_class) { create(:offence_class, class_letter: 'K') }
  let(:offence) { create(:offence, offence_class: offence_class) }
  let(:fee_type) { create(:fixed_fee_type, :fxacv) }
  let(:fee) { create(:fixed_fee, fee_type: fee_type, claim: claim, quantity: 1) }

  it { is_expected.to respond_to(:call) }

  context 'AGFS claims' do
    describe '#call' do
      subject(:response) { described_class.new(claim, params).call }

      let(:claim) do
        create(:draft_claim,
          create_defendant_and_rep_order_for_scheme_9: true,
          case_type: case_type, offence: offence
        )
      end

      let(:params) do
        {
          advocate_category: 'Junior alone',
          fee_type_id: fee.fee_type.id,
          fees: {
            "0": { fee_type_id: fee.fee_type.id, quantity: fee.quantity }
          }
        }
      end

      context 'for a case-type-specific fixed fee' do
        it_returns 'a successful fee calculator response', unit: 'day', amount: 130.0
      end

      context 'for a case-type-specific fixed fee with fixed amount (elected case not proceeded)' do
        let(:case_type) { create(:case_type, :elected_cases_not_proceeded) }
        let(:fee_type) { create(:fixed_fee_type, :fxenp) }
        let(:fee) { create(:fixed_fee, fee_type: fee_type, claim: claim, quantity: 1) }

        it_returns 'a successful fee calculator response', unit: 'day', amount: 194.0
      end

      context 'for a non-case-type-specific fixed fee (standard appearance fee/adjournments)' do
        let(:saf_fee) { create(:fixed_fee, :fxsaf_fee, claim: claim, quantity: 1) }

        before do
          params.merge!(fee_type_id: saf_fee.fee_type.id)
          params[:fees].merge!("1": { fee_type_id: saf_fee.fee_type.id, quantity: saf_fee.quantity })
        end

        it_returns 'a successful fee calculator response', unit: 'day', amount: 87.0
      end

      # TODO: deprecated fee type - to be removed
      context 'for a case-type-specific fixed fee case uplift' do
        let(:uplift_fee) { create(:fixed_fee, :fxacu_fee, claim: claim, quantity: 1) }

        before do
          params.merge!(fee_type_id: uplift_fee.fee_type.id)
          params[:fees].merge!("1": { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
        end

        it_returns 'a successful fee calculator response', unit: 'case', amount: 26.0
      end

      context 'for a fixed fee number of cases uplift' do
        let(:uplift_fee) { create(:fixed_fee, :fxnoc_fee, claim: claim, quantity: 1) }

        before do
          params.merge!(fee_type_id: uplift_fee.fee_type.id)
          params[:fees].merge!("1": { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
        end

        it_returns 'a successful fee calculator response', unit: 'case', amount: 26.0
      end

      context 'for a fixed fee number of defendants uplift' do
        let(:uplift_fee) { create(:fixed_fee, :fxndr_fee, claim: claim, quantity: 1) }

        before do
          params.merge!(fee_type_id: uplift_fee.fee_type.id)
          params[:fees].merge!("1": { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
        end

        it_returns 'a successful fee calculator response', unit: 'defendant', amount: 26.0
      end

      context 'for misc fees' do
        let(:fee) { create(:misc_fee, :miaph_fee, claim: claim, quantity: 1) }

        it_returns 'a successful fee calculator response', unit: 'halfday', amount: 130.0
      end

      context 'for a misc fee number of defendants uplift' do
        let(:fee) { create(:misc_fee, :miaph_fee, claim: claim, quantity: 1) }
        let(:uplift_fee) { create(:misc_fee, :miahu_fee, claim: claim, quantity: 2) }

        before do
          params.merge!(fee_type_id: uplift_fee.fee_type.id)
          params[:fees].merge!("1": { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
        end

        it_returns 'a successful fee calculator response', unit: 'defendant', amount: 26.0
      end

      context 'for erroneous request' do
        before { params.merge!(advocate_category: 'Not an advocate category') }

        it_returns 'a failed fee calculator response'
      end
    end
  end

  context 'LGFS claims' do
    describe '#call' do
      subject(:response) { described_class.new(claim, params).call }

      # IMPORTANT: use specific case type, offence (incl. explicit nil), fee types
      # and reporder date in order to reduce and afix VCR cassettes required (that have to match
      # on query values), prevent flickering specs (from random offence classes,
      # rep order dates) and to allow testing actual amounts "calculated".
      let(:claim) do
        create(:litigator_claim,
          create_defendant_and_rep_order_for_scheme_8: true,
          case_type: case_type,
          offence: nil
        )
      end

      let(:params) do
        {
          fee_type_id: fee.fee_type.id,
          fees: {
            "0": { fee_type_id: fee.fee_type.id, quantity: fee.quantity }
          }
        }
      end

      context 'for a case-type-specific fixed fee' do
        it_returns 'a successful fee calculator response', unit: 'day', amount: 349.47
      end

      context 'for a case-type-specific fixed fee with fixed amount (elected case not proceeded)' do
        let(:case_type) { create(:case_type, :elected_cases_not_proceeded) }
        let(:fee_type) { create(:fixed_fee_type, :fxenp) }
        let(:fee) { create(:fixed_fee, fee_type: fee_type, claim: claim, quantity: 1) }

        it_returns 'a successful fee calculator response', unit: 'day', amount: 330.33
      end

      context 'for erroneous request' do
        before { params.merge!(fee_type_id: nil) }

        it_returns 'a failed fee calculator response'
      end
    end
  end
end
