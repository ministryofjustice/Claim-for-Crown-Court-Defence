require 'rails_helper'

RSpec.shared_examples 'a successful price calculation response' do
  it 'returns http success' do
    expect(response).to have_http_status(:ok)
  end

  it 'returns JSON' do
    expect(response.body).to be_json
  end

  it 'returns success? true' do
    expect(JSON.parse(response.body)['success?']).to eql true
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
    expect(JSON.parse(response.body)['success?']).to eql false
  end

  it 'returns JSON errors array' do
    expect(JSON.parse(response.body)['errors']).to be_an Array
  end

  it 'returns JSON error message string' do
    expect(JSON.parse(response.body)['message']).to be_a String
  end
end

RSpec.describe ExternalUsers::Fees::PricesController, type: :controller do
  before(:all) { seed_fee_schemes }
  after(:all) { clean_database }

  let!(:advocate) { create(:external_user, :advocate) }

  before { sign_in advocate.user }

  describe 'POST #calculate.json' do
    context 'message sending' do
      subject(:calculate) { post :calculate, params: params }
      let(:claim) { create(:draft_claim) }

      let(:strong_params) { ActionController::Parameters.new(params).permit! }
      let(:calc_response) { instance_double(Claims::FeeCalculator::Response, success?: true) }

      context 'when UnitPrice price type specified' do
        let(:calculate_price_service) { class_double(Claims::FeeCalculator::UnitPrice).as_stubbed_const }
        let(:calculate_price) { instance_double(calculate_price_service) }
        let(:params) { { format: 'json', claim_id: "#{claim.id}", price_type: 'UnitPrice' } }

        it 'sends message to UnitPrice service' do
          expect(calculate_price_service).to receive(:new).with(claim, strong_params).and_return(calculate_price)
          expect(calculate_price).to receive(:call).and_return(calc_response)
          calculate
        end
      end

      context 'when GraduatedPrice price type specified' do
        let(:calculate_price_service) { class_double(Claims::FeeCalculator::GraduatedPrice).as_stubbed_const }
        let(:calculate_price) { instance_double(calculate_price_service) }
        let(:params) do
          {
            format: 'json',
            price_type: 'GraduatedPrice',
            claim_id: "#{claim.id}",
            fee_type_id: '1',
            advocate_category: 'QC',
            ppe: '',
            pw: '',
            days: '1'
          }
        end

        it 'sends message to GraduatedPrice service' do
          expect(calculate_price_service).to receive(:new).with(claim, strong_params).and_return(calculate_price)
          expect(calculate_price).to receive(:call).and_return(calc_response)
          calculate
        end
      end
    end

    context 'AGFS' do
      # IMPORTANT: use specific case type, offence class, fee types and reporder
      # date in order to reduce and afix VCR cassettes required (that have to match
      # on query values), prevent flickering specs (from random offence classes,
      # rep order dates) and to allow testing actual amounts "calculated".
      let(:claim) do
        create(
          :draft_claim,
          create_defendant_and_rep_order_for_scheme_9: true,
          case_type: case_type, offence: offence
        )
      end
      let(:case_type) { create(:case_type, :appeal_against_conviction) }
      let(:offence_class) { create(:offence_class, class_letter: 'K') }
      let(:offence) { create(:offence, offence_class: offence_class) }
      let(:fee_type) { create(:fixed_fee_type, :fxacv) }
      let(:fee) { create(:fixed_fee, fee_type: fee_type, claim: claim, quantity: 1) }

      let(:calculator_params) do
        {
          format: :json,
          claim_id: claim.id,
          price_type: 'UnitPrice',
          advocate_category: 'Junior alone',
          fee_type_id: fee.fee_type.id,
          fees: {
            "0": { fee_type_id: fee.fee_type.id, quantity: fee.quantity }
          }
        }
      end

      context 'success', :fee_calc_vcr do
        before do
          post :calculate, params: calculator_params
        end

        it_returns 'a successful price calculation response'
      end

      context 'failure', :fee_calc_vcr do
        before do
          calculator_params.merge!('advocate_category' => 'Rubbish')
          post :calculate, params: calculator_params
        end

        it_returns 'a failed price calculation response'
      end
    end

    context 'LGFS' do
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

      context 'success', :fee_calc_vcr do
        before do
          post :calculate, params: calculator_params
        end

        it_returns 'a successful price calculation response'
      end

      context 'failure', :fee_calc_vcr do
        before do
          calculator_params.merge!('fee_type_id' => 'Rubbish')
          post :calculate, params: calculator_params
        end

        it_returns 'a failed price calculation response'
      end
    end
  end
end
