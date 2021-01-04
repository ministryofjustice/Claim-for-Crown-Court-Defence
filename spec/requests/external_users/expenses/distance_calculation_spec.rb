require 'rails_helper'

RSpec.describe 'Distance calculation for travel expenses', type: :request do
  let(:supplier_number) { '9A999I' }
  let(:supplier_postcode) { 'MK40 3TN' }
  let!(:supplier) { create(:supplier_number, supplier_number: supplier_number, postcode: supplier_postcode) }
  let(:claim) { create(:litigator_claim, supplier_number: supplier_number) }
  let(:destination) { 'MK40 1HG' }
  let(:params) { { destination: destination } }
  let(:headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }

  context 'when the user is not authenticated' do
    it 'returns an unauthorized response' do
      post "/external_users/claims/#{claim.id}/expenses/calculate_distance.json", params: params.to_json, headers: headers

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
        post "/external_users/claims/#{claim.id}/expenses/calculate_distance.json", params: params.to_json, headers: headers

        expect(response.media_type).to eq('application/json')
        expect(response).to have_http_status(:unauthorized)
        expect(json_body).to eq('error' => 'Must be signed in as an advocate, litigator or admin user')
      end
    end

    context 'but the associated claim does not exist' do
      it 'returns an unprocessable response' do
        post '/external_users/claims/999999/expenses/calculate_distance.json', params: params.to_json, headers: headers

        expect(response.media_type).to eq('application/json')
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_body).to eq('error' => 'Cannot calculate distance without a valid claim')
      end
    end

    context 'but the associated claim is not for LGFS' do
      let(:claim) { create(:advocate_claim) }

      it 'returns an unprocessable response' do
        post "/external_users/claims/#{claim.id}/expenses/calculate_distance.json", params: params.to_json, headers: headers

        expect(response.media_type).to eq('application/json')
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_body).to eq('error' => 'Cannot calculate distance for this type of claim')
      end
    end

    context 'but the supplier associated with the claim does not have a postcode set' do
      let!(:supplier) { create(:supplier_number, supplier_number: supplier_number, postcode: nil) }

      it 'returns an unprocessable response' do
        post "/external_users/claims/#{claim.id}/expenses/calculate_distance.json", params: params.to_json, headers: headers

        expect(response.media_type).to eq('application/json')
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_body).to eq('error' => 'Supplier associated with the claim does not have a postcode')
      end
    end

    context 'but the distance cannot be calculated' do
      it 'returns nil as the calculated distance' do
        expect(Maps::DistanceCalculator).to receive(:call).with(supplier_postcode, destination).and_return(nil)

        post "/external_users/claims/#{claim.id}/expenses/calculate_distance.json", params: params.to_json, headers: headers

        expect(response.media_type).to eq('application/json')
        expect(response).to have_http_status(:ok)
        expect(json_body).to eq('distance' => nil)
      end
    end

    it 'returns the calculated return distance value' do
      expect(Maps::DistanceCalculator).to receive(:call).with(supplier_postcode, destination).and_return(847)

      post "/external_users/claims/#{claim.id}/expenses/calculate_distance.json", params: params.to_json, headers: headers

      expect(response.media_type).to eq('application/json')
      expect(response).to have_http_status(:ok)
      expect(json_body).to eq('distance' => 1694)
    end
  end
end
