RSpec.shared_examples 'injection response statuses' do
  before do
    headers.each_pair { |key, value| header key, value }
    do_request(**options)
  end

  let(:options) { {} }
  let(:headers) { {} }

  context 'with an existing claim and an authorized api key' do
    it { expect(last_response.status).to eq 200 }
  end

  context 'without an API key' do
    let(:options) { { api_key: nil } }

    it { expect(last_response.status).to eq 401 }
    it { expect(last_response.body).to include('Unauthorised') }
  end

  context 'with an unauthorized api key' do
    let(:options) { { api_key: claim.external_user.user.api_key } }

    it { expect(last_response.status).to eq 401 }
    it { expect(last_response.body).to include('Unauthorised') }
  end

  context 'with a claim uuid for an unknown claim' do
    let(:options) { { claim_uuid: '123-456-789' } }

    it { expect(last_response.status).to eq 404 }
    it { expect(last_response.body).to include('Claim not found') }
  end

  context 'with a claim of the wrong type' do
    let(:options) { { claim_uuid: invalid_claim.uuid } }

    it { expect(last_response.status).to eq 404 }
    it { expect(last_response.body).to include('Claim not found') }
  end

  context 'with an invalid API version in header' do
    let(:headers) { { 'Accept-Version' => 'v1' } }

    it { expect(last_response.status).to eq 406 }
    it { expect(last_response.body).to include('The requested version is not supported.') }
  end
end

RSpec.shared_examples 'injection data with defendants' do
  subject(:response) { do_request.body }

  let(:defendants) { create_list(:defendant, 2) }

  it 'returns multiple defendants' do
    is_expected.to have_json_size(2).at_path('defendants')
  end

  it 'returns defendants in order created marking earliest created as the "main" defendant' do
    is_expected.to be_json_eql('true').at_path('defendants/0/main_defendant')
  end

  context 'with representation orders' do
    let(:defendants) do
      [
        create(
          :defendant,
          representation_orders: create_list(:representation_order, 2, representation_order_date: 5.days.ago)
        ),
        create(
          :defendant,
          representation_orders: create_list(:representation_order, 1, representation_order_date: 2.days.ago)
        )
      ]
    end

    it 'returns the earliest of the representation orders' do
      is_expected.to have_json_size(1).at_path('defendants/0/representation_orders')
    end

    it 'returns earliest rep order first (per defendant)' do
      is_expected
        .to be_json_eql(claim.earliest_representation_order_date.to_json)
        .at_path('defendants/0/representation_orders/0/representation_order_date')
    end
  end
end
