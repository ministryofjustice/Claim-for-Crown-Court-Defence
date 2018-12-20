RSpec.describe Claims::FeeCalculator::GraduatedPrice, :fee_calc_vcr do
  subject { described_class.new(claim, params) }

  # IMPORTANT: use specific case type, offence class, fee types and reporder
  # date in order to reduce and afix VCR cassettes required (that have to match
  # on query values), prevent flickering specs (from random offence classes,
  # rep order dates) and to allow testing actual amounts "calculated".
  let(:claim) { create(
        :litigator_claim,
        create_defendant_and_rep_order_for_scheme_8: true,
        case_type: case_type,
        offence: offence,
        actual_trial_length: 10
      )
  }
  let(:case_type) { create(:case_type, :trial) }
  let(:offence_class) { create(:offence_class, class_letter: 'J') }
  let(:offence) { create(:offence, offence_class: offence_class) }
  let(:fee_type) { create(:graduated_fee_type, :grtrl) }
  let(:fee) do
    create(
      :graduated_fee,
      claim: claim,
      fee_type: fee_type,
      date: scheme_date_for('lgfs'),
      quantity: 1
    )
  end

  it { is_expected.to respond_to(:call) }
  it { is_expected.to respond_to(:days) }
  it { is_expected.to respond_to(:ppe) }

  let(:params) do
    {
      fee_type_id: fee.fee_type.id,
      days: claim.actual_trial_length,
      ppe: fee.quantity
    }
  end

  describe '#call' do
    subject(:response) { described_class.new(claim, params).call }

    context 'LGFS' do
      context 'final claim' do
        it_returns 'a successful fee calculator response', amount: 5142.87

        context 'when 2 defendants' do
          before do
            claim.defendants << create(:defendant, scheme: 'lgfs')
          end

          # TODO: modify once retrospectively using actual number of defendants
          # for fee calc and defendant uplift misc fee removed
          context 'price is unaffected' do
            it_returns 'a successful fee calculator response', amount: 5142.87
          end
        end
      end

      context 'transfer claim' do
        # IMPORTANT: use specific case type, offence class, fee types and reporder
        # date in order to reduce and afix VCR cassettes required (that have to match
        # on query values), prevent flickering specs (from random offence classes,
        # rep order dates) and to allow testing actual amounts "calculated".
        let(:claim) {
          create(
            :transfer_claim,
            create_defendant_and_rep_order_for_scheme_8: true,
            offence: offence,
            actual_trial_length: 10,
            litigator_type: 'new',
            elected_case: false,
            transfer_stage_id: 20, # Before trial transfer
            transfer_date: 3.months.ago,
            case_conclusion_id: 30 # Cracked
          )
        }

        it_returns 'a successful fee calculator response', amount: 904.58

        context 'when 2 defendants' do
          before do
            claim.defendants << create(:defendant, scheme: 'lgfs')
          end

          # TODO: modify once retrospectively using actual number of defendants
          # for fee calc and defendant uplift misc fee removed
          context 'price is unaffected' do
            it_returns 'a successful fee calculator response', amount: 904.58
          end
        end
      end

      context 'interim claims' do
        let(:claim) {
          create(
            :interim_claim,
            create_defendant_and_rep_order_for_scheme_8: true,
            offence: offence
          )
        }

        context 'effective PCMH' do
          let(:fee) { create(:interim_fee, :effective_pcmh, claim: claim, quantity: 100) }
          let(:params) { { fee_type_id: fee.fee_type.id, days: nil, ppe: fee.quantity } }

          it_returns 'a successful fee calculator response', amount: 838.94
        end

        context 'trial start', skip: 'temporary skip until error in fee calc api can be sorted out' do
          before { claim.estimated_trial_length = 3 }
          let(:fee) { create(:interim_fee, :trial_start, claim: claim, quantity: 100) }
          let(:params) { { fee_type_id: fee.fee_type.id, days: claim.estimated_trial_length, ppe: fee.quantity } }

          it_returns 'a successful fee calculator response', amount: 1799.18
        end

        context 'retrial start', skip: 'temporary skip until error in fee calc api can be sorted out' do
          before { claim.retrial_estimated_length = 3 }
          let(:fee) { create(:interim_fee, :retrial_start, claim: claim, quantity: 96) }
          let(:params) { { fee_type_id: fee.fee_type.id, days: claim.retrial_estimated_length, ppe: fee.quantity } }

          it_returns 'a successful fee calculator response', amount: 1732.86
        end

        context 'retrial (new solicitor)' do
          let(:fee) { create(:interim_fee, :retrial_new_solicitor, claim: claim, quantity: 81) }
          let(:params) { { fee_type_id: fee.fee_type.id, days: nil, ppe: fee.quantity } }

          it_returns 'a successful fee calculator response', amount: 457.64
        end

        # TODO: these need special handling
        context 'warrant' do
        end
      end

      context 'when api call fails' do
        before do
          stub_request(:get, %r{\Ahttps://laa-fee-calculator(.*).k8s.integration.dsd.io/api/v1/.*\z}).
            to_return(status: 404, body: {'error': '"detail": "Not found."'}.to_json, headers: {})
        end

        it_returns 'a failed fee calculator response', message: /not found/i
      end
    end

    context 'AGFS claims', skip: '# TODO: once AGFS grad fee calc is implemented' do
    end
  end
end
