shared_examples "fee validate endpoint" do

  it 'valid requests should return 200 and String true' do
    response = post_to_validate_endpoint(valid_params)
    expect(response.status).to eq 200
    json = JSON.parse(response.body)
    expect(json).to eq({ "valid" => true })
  end

  it 'missing required params should return 400 and a JSON error array' do
    valid_params.delete(:fee_type_id)
    response = post_to_validate_endpoint(valid_params)
    expect(response.status).to eq 400
    expect(response.body).to eq(json_error_response)
  end

  it 'invalid claim id should return 400 and a JSON error array' do
    valid_params[:claim_id] = SecureRandom.uuid
    response = post_to_validate_endpoint(valid_params)
    expect(response.status).to eq 400
    expect(response.body).to eq "[{\"error\":\"Claim can't be blank\"}]"
  end

end