require 'rails_helper'

describe 'POSTING to root' do
  let!(:provider) { create(:provider) }
  let!(:claim)    { create(:claim, source: 'api').reload }
  let(:payload)   do
    { api_key: provider.api_key, claim_id: claim.uuid, first_name: 'JohnAPI', last_name: 'SmithAPI',
      date_of_birth: '1980-05-10' }
  end

  before { post '/', params: payload.merge(format: :json) }

  it 'returns an error' do
    expect(response).to have_http_status(:forbidden)
  end
end
