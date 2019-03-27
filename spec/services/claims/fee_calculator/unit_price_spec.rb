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

      context 'graduated fees' do
        context 'daily attendance fees' do
          context 'on a trial' do
            let(:case_type) { create(:case_type, :trial) }

            context 'scheme 9' do
              context 'for a daily attendance (3 to 40)' do
                let(:fee_type) { create(:basic_fee_type, :daf) }
                let(:fee) { create(:basic_fee, fee_type: fee_type, claim: claim, quantity: 1) }

                it_returns 'a successful fee calculator response', unit: 'day', amount: 530.00
              end

              context 'for a daily attendance (41 to 50)' do
                let(:fee_type) { create(:basic_fee_type, :dah) }
                let(:fee) { create(:basic_fee, fee_type: fee_type, claim: claim, quantity: 1) }

                it_returns 'a successful fee calculator response', unit: 'day', amount: 266.00
              end

              context 'for a daily attendance (51+)' do
                let(:fee_type) { create(:basic_fee_type, :daj) }
                let(:fee) { create(:basic_fee, fee_type: fee_type, claim: claim, quantity: 1) }

                it_returns 'a successful fee calculator response', unit: 'day', amount: 285.00
              end
            end

            context 'scheme 10' do
              before { params.merge!(advocate_category: 'Junior') }

              let(:offence_band) { create(:offence_band, :for_standard) }
              let(:offence) { create(:offence, :with_fee_scheme_ten, offence_band: offence_band) }
              let(:claim) { create(:draft_claim, case_type: case_type, offence: offence, create_defendant_and_rep_order_for_scheme_10: true) }

              context 'for a daily attendance (2+)' do
                let(:fee_type) { create(:basic_fee_type, :dat) }
                let(:fee) { create(:basic_fee, fee_type: fee_type, claim: claim, quantity: 1) }

                it_returns 'a successful fee calculator response', unit: 'day', amount: 300.00
              end
            end
          end
        end
      end

      context 'fixed fees' do
        let(:fee_type) { create(:fixed_fee_type, :fxacv) }
        let(:fee) { create(:fixed_fee, fee_type: fee_type, claim: claim, quantity: 1) }

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
      end

      context 'miscellaneous fees' do
        context 'for non-(defendant)-uplift misc fees' do
          let(:fee) { create(:misc_fee, :miaph_fee, claim: claim, quantity: 1) }

          context 'on claims with a case type' do
            it_returns 'a successful fee calculator response', unit: 'halfday', amount: 130.0
          end

          context 'on (supplementary) claims with no case type' do
            before do
              claim.case_type = nil
              allow(claim).to receive(:supplementary?).and_return true
            end

            it_returns 'a successful fee calculator response', unit: 'halfday', amount: 130.0
          end
        end

        context 'for a (defendant) uplift fee' do
          let(:fee) { create(:misc_fee, :miaph_fee, claim: claim, quantity: 1) }
          let(:uplift_fee) { create(:misc_fee, :miahu_fee, claim: claim, quantity: 2) }

          before do
            params.merge!(fee_type_id: uplift_fee.fee_type.id)
            params[:fees].merge!("1": { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
          end

          it_returns 'a successful fee calculator response', unit: 'defendant', amount: 26.0
        end
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
