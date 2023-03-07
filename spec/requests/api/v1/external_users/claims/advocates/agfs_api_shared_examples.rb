# frozen_string_literal: true

RSpec.shared_context 'with AGFS API users' do
  let(:default_params) { { api_key: vendor.provider.api_key } }
  let(:vendor) { create(:external_user, :admin) }
  let(:advocate) { create(:external_user, :advocate, provider: vendor.provider) }
end

RSpec.shared_examples 'API creation successful' do
  it { expect(response).to be_successful }

  it 'sets advocate category correctly in the claim' do
    expect(Claim::BaseClaim.last.advocate_category).to eq advocate_category
  end
end

RSpec.shared_examples 'API validation successful' do
  it { expect(response).to be_successful }
  it { expect(response.parsed_body['valid']).to be_truthy }
end

RSpec.shared_examples 'API request fails with ineligible advocate category' do
  it { expect(response).to have_http_status(:bad_request) }
  it { expect(response.parsed_body.first['error']).to eq('Choose an eligible advocate category') }
end

RSpec.shared_examples 'claim with AGFS reform advocate categories' do
  before do
    submit_request
  end

  context 'when creating' do
    subject(:submit_request) { post(endpoint.create, params:) }

    context 'with a Junior advocate category' do
      let(:advocate_category) { 'Junior' }

      include_examples 'API creation successful'
    end

    context 'with a Leading junior advocate category' do
      let(:advocate_category) { 'Leading junior' }

      include_examples 'API creation successful'
    end

    context 'with a QC advocate category' do
      let(:advocate_category) { 'QC' }

      include_examples 'API creation successful'
    end

    context 'with a KC advocate category' do
      let(:advocate_category) { 'KC' }

      it { expect(response).to be_successful }

      it 'translates advocate category KC to QC before creating claim' do
        expect(Claim::BaseClaim.last.advocate_category).to eq 'QC'
      end
    end

    context 'with an unknown advocate category' do
      let(:advocate_category) { 'Unknown' }

      it { expect(response).to have_http_status(:bad_request) }
      it { expect(response.parsed_body.first['error']).to eq('advocate_category does not have a valid value') }
    end
  end

  context 'when validating' do
    subject(:submit_request) { post(endpoint.validate, params:) }

    context 'with a Junior advocate category' do
      let(:advocate_category) { 'Junior' }

      include_examples 'API validation successful'
    end

    context 'with a Leading junior advocate category' do
      let(:advocate_category) { 'Leading junior' }

      include_examples 'API validation successful'
    end

    context 'with a QC advocate category' do
      let(:advocate_category) { 'QC' }

      include_examples 'API validation successful'
    end

    context 'with a KC advocate category' do
      let(:advocate_category) { 'KC' }

      include_examples 'API validation successful'
    end

    context 'with an unknown advocate category' do
      let(:advocate_category) { 'Unknown' }

      it { expect(response).to have_http_status(:bad_request) }
      it { expect(response.parsed_body.first['error']).to eq('advocate_category does not have a valid value') }
    end
  end
end

RSpec.shared_examples 'claim with pre-AGFS reform advocate categories' do
  before do
    submit_request
  end

  context 'when creating' do
    subject(:submit_request) { post(endpoint.create, params:) }

    context 'with a Led junior advocate category' do
      let(:advocate_category) { 'Led junior' }

      include_examples 'API request fails with ineligible advocate category'
    end

    context 'with a Junior alone advocate category' do
      let(:advocate_category) { 'Junior alone' }

      include_examples 'API request fails with ineligible advocate category'
    end
  end

  context 'when validating' do
    subject(:submit_request) { post(endpoint.validate, params:) }

    before do
      submit_request
    end

    context 'with a Led junior advocate category' do
      let(:advocate_category) { 'Led junior' }

      include_examples 'API request fails with ineligible advocate category'
    end

    context 'with a Junior alone advocate category' do
      let(:advocate_category) { 'Junior alone' }

      include_examples 'API request fails with ineligible advocate category'
    end
  end
end
