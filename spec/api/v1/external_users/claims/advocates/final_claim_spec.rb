require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Claims::Advocates::FinalClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  FINAL_CLAIM_ENDPOINT = 'advocates/final'.freeze

  let(:claim_class) { Claim::AdvocateClaim }
  let!(:provider)       { create(:provider) }
  let!(:other_provider) { create(:provider) }
  let!(:vendor)         { create(:external_user, :admin, provider: provider) }
  let!(:advocate)       { create(:external_user, :advocate, provider: provider) }
  let!(:other_vendor)   { create(:external_user, :admin, provider: other_provider) }
  let!(:offence)        { create(:offence) }
  let!(:court)          { create(:court) }
  let!(:valid_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: advocate.user.email,
      case_type_id: FactoryBot.create(:case_type, :retrial).id,
      case_number: 'A20161234',
      first_day_of_trial: "2015-01-01",
      estimated_trial_length: 10,
      actual_trial_length: 9,
      trial_concluded_at: "2015-01-09",
      retrial_started_at: "2015-02-01",
      retrial_concluded_at: "2015-02-05",
      retrial_actual_length: "4",
      retrial_estimated_length: "5",
      retrial_reduction: "true",
      advocate_category: 'Led junior',
      offence_id: offence.id,
      court_id: court.id
    }
  end

  subject(:post_to_validate_endpoint) { post ClaimApiEndpoints.for(FINAL_CLAIM_ENDPOINT).validate, valid_params, format: :json }

  after(:all) { clean_database }

  include_examples 'advocate claim test setup'
  it_behaves_like 'a claim endpoint', relative_endpoint: FINAL_CLAIM_ENDPOINT
  it_behaves_like 'a claim validate endpoint', relative_endpoint: FINAL_CLAIM_ENDPOINT
  it_behaves_like 'a claim create endpoint', relative_endpoint: FINAL_CLAIM_ENDPOINT

  # TODO: write a generic date error handling spec and share
  describe "POST #{ClaimApiEndpoints.for(FINAL_CLAIM_ENDPOINT).validate}" do
    it 'returns 400 and JSON error when dates are not in acceptable format' do
      valid_params[:first_day_of_trial] = '01-01-2015'
      valid_params[:trial_concluded_at] = '09-01-2015'
      valid_params[:trial_fixed_notice_at] = '01-01-2015'
      valid_params[:trial_fixed_at] = '01-01-2015'
      valid_params[:trial_cracked_at] = '01-01-2015'
      valid_params[:retrial_started_at] = '01-01-2015'
      valid_params[:retrial_concluded_at] = '01-01-2015'
      post_to_validate_endpoint
      expect(last_response.status).to eq(400)
      body = last_response.body
      [
        'first_day_of_trial is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
        'trial_concluded_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
        'trial_fixed_notice_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
        'trial_fixed_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
        'trial_cracked_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
        'retrial_started_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
        'retrial_concluded_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])'
      ].each do |error|
        expect(body).to include(error)
      end
    end
  end

  context 'when validating case_number' do
    it 'returns 400 and JSON error when URN is too long' do
      valid_params[:case_number] = 'ABCDEFGHIJABCDEFGHIJA'
      post_to_validate_endpoint
      expect(last_response.status).to eq(400)
      body = last_response.body
      expect(body).to include('The case number must be a case number (e.g. A20161234) or unique reference number (less than 21 letters and numbers)')
    end

    it 'returns 400 and JSON error when URN contains a special character' do
      valid_params[:case_number] = 'ABCDEFGHIJABCDEFGHI_'
      post_to_validate_endpoint
      expect(last_response.status).to eq(400)
      body = last_response.body
      expect(body).to include('The case number must be a case number (e.g. A20161234) or unique reference number (less than 21 letters and numbers)')
    end

    it 'returns 400 and JSON error when the case number does not start with a BAST or U' do
      valid_params[:case_number] = 'G20209876'
      post_to_validate_endpoint
      expect(last_response.status).to eq(400)
      body = last_response.body
      expect(body).to include('The case number must be in the format A20161234')
    end

    it 'returns 400 and JSON error when the case number is too long' do
      valid_params[:case_number] = 'T202098761'
      post_to_validate_endpoint
      expect(last_response.status).to eq(400)
      body = last_response.body
      expect(body).to include('The case number must be in the format A20161234')
    end

    it 'returns 400 and JSON error when the case number is too short' do
      valid_params[:case_number] = 'T2020987'
      post_to_validate_endpoint
      expect(last_response.status).to eq(400)
      body = last_response.body
      expect(body).to include('The case number must be in the format A20161234')
    end

    it 'returns 200 and valid when case_number is a valid common platform URN' do
      valid_params[:case_number] = 'ABCDEFGHIJ1234567890'
      post_to_validate_endpoint
      expect(last_response.status).to eq(200)
      body = last_response.body
      expect(body).to include('valid')
    end

    it 'returns 200 and valid when the URN is a valid URN containing a year' do
      valid_params[:case_number] = '120207575'
      post_to_validate_endpoint
      expect(last_response.status).to eq(200)
      body = last_response.body
      expect(body).to include('valid')
    end

    it 'returns 200 and valid when case_number is a valid case number' do
      valid_params[:case_number] = 'T20202601'
      post_to_validate_endpoint
      expect(last_response.status).to eq(200)
      body = last_response.body
      expect(body).to include('valid')
    end
  end
end
