require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Claims::Advocates::FinalClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  FINAL_CLAIM_ENDPOINT = 'advocates/final'.freeze

  subject(:post_to_validate_endpoint) do
    post ClaimApiEndpoints.for(FINAL_CLAIM_ENDPOINT).validate, valid_params, format: :json
  end

  let(:claim_class)     { Claim::AdvocateClaim }
  let!(:provider)       { create(:provider) }
  let!(:vendor)         { create(:external_user, :admin, provider:) }
  let!(:advocate)       { create(:external_user, :advocate, provider:) }
  let!(:offence)        { create(:offence) }
  let!(:court)          { create(:court) }
  let!(:valid_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: advocate.user.email,
      case_type_id: create(:case_type, :retrial).id,
      case_number: 'A20161234',
      first_day_of_trial: '2015-01-01',
      estimated_trial_length: 10,
      actual_trial_length: 9,
      trial_concluded_at: '2015-01-09',
      retrial_started_at: '2015-02-01',
      retrial_concluded_at: '2015-02-05',
      retrial_actual_length: '4',
      retrial_estimated_length: '5',
      retrial_reduction: 'true',
      advocate_category: 'Led junior',
      offence_id: offence.id,
      court_id: court.id,
      main_hearing_date: '2015-02-05'
    }
  end

  after { clean_database }

  context 'when CLAIR contingency functionality is disabled' do
    before { valid_params.except!(:main_hearing_date) }

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
        [
          'first_day_of_trial is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
          'trial_concluded_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
          'trial_fixed_notice_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
          'trial_fixed_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
          'trial_cracked_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
          'retrial_started_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
          'retrial_concluded_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])'
        ].each do |error|
          expect(last_response.status).to eq(400)
          expect(last_response.body).to include(error)
        end
      end
    end
  end

  context 'when CLAIR contingency functionality is enabled',
          skip: 'Skipped pending removal of the main_hearing_date feature flag' do
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
        valid_params[:main_hearing_date] = '01-01-2015'
        post_to_validate_endpoint
        [
          'first_day_of_trial is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
          'trial_concluded_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
          'trial_fixed_notice_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
          'trial_fixed_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
          'trial_cracked_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
          'retrial_started_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
          'retrial_concluded_at is not in an acceptable date format (YYYY-MM-DD[T00:00:00])',
          'main_hearing_date is not in an acceptable date format (YYYY-MM-DD[T00:00:00])'
        ].each do |error|
          expect(last_response.status).to eq(400)
          expect(last_response.body).to include(error)
        end
      end
    end
  end

  context 'when validating case_number' do
    let(:case_number_error) { 'The case number must be a case number (e.g. A20161234) or unique reference number' }
    let(:case_number_format_error) { 'The case number must be in the format A20161234' }

    before do
      valid_params[:case_number] = case_number
      post_to_validate_endpoint
    end

    context 'when URN is too long' do
      let(:case_number) { 'ABCDEFGHIJABCDEFGHIJA' }

      it { expect(last_response.status).to eq(400) }
      it { expect(last_response.body).to include(case_number_error) }
    end

    context 'when URN contains a special character' do
      let(:case_number) { 'ABCDEFGHIJABCDEFGHI_' }

      it { expect(last_response.status).to eq(400) }
      it { expect(last_response.body).to include(case_number_error) }
    end

    context 'when the case number does not start with a BAST or U' do
      let(:case_number) { 'G20209876' }

      it { expect(last_response.status).to eq(400) }
      it { expect(last_response.body).to include(case_number_format_error) }
    end

    context 'when the case number is too long' do
      let(:case_number) { 'T202098761' }

      it { expect(last_response.status).to eq(400) }
      it { expect(last_response.body).to include(case_number_format_error) }
    end

    context 'when the case number is too short' do
      let(:case_number) { 'T2020987' }

      it { expect(last_response.status).to eq(400) }
      it { expect(last_response.body).to include(case_number_format_error) }
    end

    context 'when case_number is a valid common platform URN' do
      let(:case_number) { 'ABCDEFGHIJ1234567890' }

      it { expect(last_response.status).to eq(200) }
      it { expect(last_response.body).to include('valid') }
    end

    context 'when case_number is a valid URN containing a year' do
      let(:case_number) { '120207575' }

      it { expect(last_response.status).to eq(200) }
      it { expect(last_response.body).to include('valid') }
    end

    context 'when case_number is a valid case number' do
      let(:case_number) { 'T20202601' }

      it { expect(last_response.status).to eq(200) }
      it { expect(last_response.body).to include('valid') }
    end
  end
end
