require 'rails_helper'

RSpec.shared_examples 'a successful price calculation response' do
  it 'returns http success' do
    expect(response).to have_http_status(:ok)
  end

  it 'returns JSON' do
    expect(response.body).to be_json
  end

  it 'returns success? true' do
    expect(response.parsed_body['success?']).to be true
  end
end

RSpec.shared_examples 'a failed price calculation response' do
  it 'returns unprocessible entity' do
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'returns JSON' do
    expect(response.body).to be_json
  end

  it 'returns success? false' do
    expect(response.parsed_body['success?']).to be false
  end

  it 'returns JSON errors array' do
    expect(response.parsed_body['errors']).to be_an Array
  end

  it 'returns JSON error message string' do
    expect(response.parsed_body['message']).to be_a String
  end
end

RSpec.describe ExternalUsers::Fees::PricesController do
  after(:all) { clean_database }

  let!(:advocate) { create(:external_user, :advocate) }

  before { sign_in advocate.user }

  describe 'POST #calculate.json' do
    context 'when sending message' do
      subject(:calculate) { post :calculate, params: }

      let(:claim) { create(:draft_claim) }

      let(:strong_params) { ActionController::Parameters.new(params).permit! }
      let(:calc_response) { instance_double(Claims::FeeCalculator::Response, success?: true) }

      context 'when UnitPrice price type specified' do
        let(:calculate_price_service) { Claims::FeeCalculator::UnitPrice }
        let(:calculate_price) { instance_double(calculate_price_service) }
        let(:params) { { format: 'json', claim_id: claim.id.to_s, price_type: 'UnitPrice' } }

        before do
          allow(calculate_price_service).to receive(:new).with(claim, strong_params).and_return(calculate_price)
          allow(calculate_price).to receive(:call).and_return(calc_response)

          calculate
        end

        it 'sends message to UnitPrice service' do
          expect(calculate_price_service).to have_received(:new).with(claim, strong_params)
        end

        it 'calls the UnitPrice service' do
          expect(calculate_price).to have_received(:call)
        end
      end

      context 'with Incorrect price type specified', :fee_calc_vcr do
        let(:params) { { format: 'json', claim_id: claim.id.to_s, price_type: 'BillScenario' } }

        before { calculate }

        it_returns 'a failed price calculation response'
      end

      context 'when GraduatedPrice price type specified' do
        let(:calculate_price_service) { Claims::FeeCalculator::GraduatedPrice }
        let(:calculate_price) { instance_double(calculate_price_service) }
        let(:params) do
          {
            format: 'json',
            price_type: 'GraduatedPrice',
            claim_id: claim.id.to_s,
            fee_type_id: '1',
            advocate_category: 'QC',
            ppe: '',
            pw: '',
            days: '1'
          }
        end

        before do
          allow(calculate_price_service).to receive(:new).with(claim, strong_params).and_return(calculate_price)
          allow(calculate_price).to receive(:call).and_return(calc_response)

          calculate
        end

        it 'sends message to GraduatedPrice service' do
          expect(calculate_price_service).to have_received(:new).with(claim, strong_params)
        end

        it 'calls the GraduatedPrice service' do
          expect(calculate_price).to have_received(:call)
        end
      end
    end

    context 'with AGFS' do
      # IMPORTANT: use specific case type, offence class, fee types and reporder
      # date in order to reduce and afix VCR cassettes required (that have to match
      # on query values), prevent flickering specs (from random offence classes,
      # rep order dates) and to allow testing actual amounts "calculated".
      let(:claim) do
        create(
          :draft_claim,
          create_defendant_and_rep_order_for_scheme_9: true,
          case_type:, offence:
        )
      end
      let(:case_type) { create(:case_type, :appeal_against_conviction) }
      let(:offence_class) { create(:offence_class, class_letter: 'K') }
      let(:offence) { create(:offence, offence_class:) }
      let(:fee_type) { create(:fixed_fee_type, :fxacv) }
      let(:fee) { create(:fixed_fee, fee_type:, claim:, quantity: 1) }

      let(:calculator_params) do
        {
          format: :json,
          claim_id: claim.id,
          price_type: 'UnitPrice',
          advocate_category: 'Junior alone',
          fee_type_id: fee.fee_type.id,
          fees: {
            '0': { fee_type_id: fee.fee_type.id, quantity: fee.quantity }
          }
        }
      end

      context 'with success', :fee_calc_vcr do
        before do
          post :calculate, params: calculator_params
        end

        it_returns 'a successful price calculation response'
      end

      context 'with failure', :fee_calc_vcr do
        before do
          calculator_params['advocate_category'] = 'Rubbish'
          post :calculate, params: calculator_params
        end

        it_returns 'a failed price calculation response'
      end
    end

    context 'with LGFS' do
      # IMPORTANT: use specific case type, offence class, fee types and reporder
      # date in order to reduce and afix VCR cassettes required (that have to match
      # on query values), prevent flickering specs (from random offence classes,
      # rep order dates) and to allow testing actual amounts "calculated".
      let(:claim) do
        create(
          :litigator_claim,
          create_defendant_and_rep_order_for_scheme_9: true,
          case_type:,
          offence:,
          actual_trial_length: 10
        )
      end
      let(:case_type) { create(:case_type, :trial) }
      let(:offence_class) { create(:offence_class, class_letter: 'J') }
      let(:offence) { create(:offence, offence_class:) }
      let(:fee_type) { create(:graduated_fee_type, :grtrl) }
      let(:fee) do
        create(
          :graduated_fee,
          claim:,
          fee_type:,
          date: DateTime.parse('2018-03-31'),
          quantity: 1
        )
      end

      let(:calculator_params) do
        {
          format: :json,
          claim_id: claim.id,
          price_type: 'GraduatedPrice',
          fee_type_id: fee.fee_type.id,
          days: claim.actual_trial_length,
          ppe: fee.quantity
        }
      end

      context 'with success', :fee_calc_vcr do
        before do
          post :calculate, params: calculator_params
        end

        it_returns 'a successful price calculation response'
      end

      context 'with failure', :fee_calc_vcr do
        before do
          calculator_params['fee_type_id'] = 'Rubbish'
          post :calculate, params: calculator_params
        end

        it_returns 'a failed price calculation response'
      end
    end
  end
end
