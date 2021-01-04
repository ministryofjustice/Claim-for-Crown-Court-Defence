shared_examples 'fee validate endpoint' do
  it 'valid requests should return 200 and String true' do
    post_to_validate_endpoint
    expect(last_response.status).to eq 200
    json = JSON.parse(last_response.body)
    expect(json).to eq({ 'valid' => true })
  end

  it 'missing required params should return 400 and a JSON error array' do
    valid_params.delete(:fee_type_id)
    post_to_validate_endpoint
    expect(last_response.status).to eq 400
    expect(last_response.body).to eq(json_error_response)
  end

  it 'invalid claim id should return 400 and a JSON error array' do
    valid_params[:claim_id] = SecureRandom.uuid
    post_to_validate_endpoint
    expect(last_response.status).to eq 400
    expect(last_response.body).to eq '[{"error":"Claim cannot be blank"}]'
  end
end
