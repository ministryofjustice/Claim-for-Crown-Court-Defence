require 'rails_helper'

RSpec.describe ExternalUsers::Fees::PricesController, type: :controller do
  let!(:advocate) { create(:external_user, :advocate) }
  let(:claim) { create(:draft_claim) }

  before { sign_in advocate.user }

  describe "POST #calculate" do
    subject(:calculate) { post :calculate, params: params }

    let(:strong_params) { ActionController::Parameters.new(params).permit! }
    let(:calc_response) { instance_double(Claims::FeeCalculator::Response, success?: true) }

    context 'when UnitPrice price type specified' do
      let(:calculate_price_service) { class_double(Claims::FeeCalculator::UnitPrice).as_stubbed_const }
      let(:calculate_price) { instance_double(calculate_price_service) }
      let(:params) { { format: 'json', claim_id: "#{claim.id}", price_type: 'UnitPrice' } }

      it 'sends message to applicable service object' do
        expect(calculate_price_service).to receive(:new).with(claim, strong_params).and_return(calculate_price)
        expect(calculate_price).to receive(:call).and_return(calc_response)
        calculate
      end
    end

    context 'when GraduatedPrice price type specified' do
      let(:calculate_price_service) { class_double(Claims::FeeCalculator::GraduatedPrice).as_stubbed_const }
      let(:calculate_price) { instance_double(calculate_price_service) }
      let(:params) { { format: 'json', claim_id: "#{claim.id}", price_type: 'GraduatedPrice' } }

      it 'sends message to applicable service object' do
        expect(calculate_price_service).to receive(:new).with(claim, strong_params).and_return(calculate_price)
        expect(calculate_price).to receive(:call).and_return(calc_response)
        calculate
      end
    end

    context 'JSON response' do
      let(:calculate_price_service) { class_double(Claims::FeeCalculator::Calculate).as_stubbed_const }
      let(:calculate_price) { instance_double(calculate_price_service) }
      let(:params) { { format: :json, claim_id: "#{claim.id}", price_type: 'Calculate' } }

      before do
        allow(calculate_price_service).to receive(:new).and_return(calculate_price)
        allow(calculate_price).to receive(:call).and_return(calc_response)
      end

      context 'when calculator service responds with success' do
        let(:calc_response) { instance_double(Claims::FeeCalculator::Response, success?: true) }

        it { is_expected.to have_http_status(200) }
      end

      context 'when calculator service responds with failure' do
        let(:calc_response) { instance_double(Claims::FeeCalculator::Response, success?: false) }

        it { is_expected.to have_http_status(422) }
      end
    end
  end
end
