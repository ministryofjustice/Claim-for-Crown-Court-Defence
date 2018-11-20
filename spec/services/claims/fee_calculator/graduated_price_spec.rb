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
      date: DateTime.parse('2018-03-31'),
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

    context 'LGFS claims' do
      it_returns 'a successful fee calculator response', amount: 5142.87

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
