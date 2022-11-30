require 'rails_helper'

RSpec.describe 'Distance calculation for travel expenses' do
  subject(:calculate_distance) do
    post(
      "/external_users/claims/#{claim_id}/expenses/calculate_distance.json",
      params: { destination: }.to_json,
      headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    )
  end

  let(:supplier_number) { '9A999I' }
  let(:supplier_postcode) { 'MK40 3TN' }
  let(:claim) { create(:litigator_claim, supplier_number:) }
  let(:claim_id) { claim.id }
  let(:destination) { 'MK40 1HG' }

  before do
    create(:supplier_number, supplier_number:, postcode: supplier_postcode)
    allow(DistanceCalculatorService::Directions)
      .to receive(:new).with(supplier_postcode, destination).and_return(OpenStruct.new(max_distance: 847))
  end

  context 'when the user is not authenticated' do
    it 'returns an unauthorized response' do
      calculate_distance

      expect(response.media_type).to eq('application/json')
      expect(response).to have_http_status(:unauthorized)
      expect(json_body).to eq('error' => 'Must be signed in as an advocate, litigator or admin user')
    end
  end

  context 'when the user is authenticated' do
    let(:user) { create(:external_user, :litigator).user }

    before do
      sign_in(user)
    end

    context 'but is not authorized to perform this request' do
      let(:user) { create(:case_worker).user }

      it 'returns an unauthorized response' do
        calculate_distance

        expect(response.media_type).to eq('application/json')
        expect(response).to have_http_status(:unauthorized)
        expect(json_body).to eq('error' => 'Must be signed in as an advocate, litigator or admin user')
      end
    end

    context 'but the associated claim does not exist' do
      let(:claim_id) { 999_999 }

      it 'returns an unprocessable response' do
        calculate_distance

        expect(response.media_type).to eq('application/json')
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_body).to eq('error' => 'Cannot calculate distance without a valid claim')
      end
    end

    context 'but the associated claim is not for LGFS' do
      let(:claim) { create(:advocate_claim) }

      it 'returns an unprocessable response' do
        calculate_distance

        expect(response.media_type).to eq('application/json')
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_body).to eq('error' => 'Cannot calculate distance for this type of claim')
      end
    end

    context 'but the supplier associated with the claim does not have a postcode set' do
      let(:supplier_postcode) { nil }

      it 'returns an unprocessable response' do
        calculate_distance

        expect(response.media_type).to eq('application/json')
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_body).to eq('error' => 'Supplier associated with the claim does not have a postcode')
      end
    end

    context 'but the distance cannot be calculated' do
      before do
        allow(DistanceCalculatorService::Directions)
          .to receive(:new).with(supplier_postcode, destination).and_return(OpenStruct.new(max_distance: nil))
      end

      it 'returns nil as the calculated distance' do
        calculate_distance

        expect(response.media_type).to eq('application/json')
        expect(response).to have_http_status(:ok)
        expect(json_body).to eq('distance' => nil)
      end
    end

    it 'returns the calculated return distance value' do
      calculate_distance

      expect(response.media_type).to eq('application/json')
      expect(response).to have_http_status(:ok)
      expect(json_body).to eq('distance' => 1694)
    end
  end
end
