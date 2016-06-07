shared_examples "invalid API key validate endpoint" do
  it "should return 401 and JSON error array when it is not provided" do
    valid_params[:api_key] = nil
    post_to_validate_endpoint
    expect_unauthorised_error
  end

  it "should return 401 and JSON error array when it does not match an existing provider API key" do
    valid_params[:api_key] = SecureRandom.uuid
    post_to_validate_endpoint
    expect_unauthorised_error
  end

  it "should return 401 and JSON error array when it is malformed" do
    valid_params[:api_key] = 'any-old-rubbish'
    post_to_validate_endpoint
    expect_unauthorised_error
  end
end

shared_examples "invalid API key create endpoint" do
  it "should return 401 and JSON error array when it is not provided" do
    valid_params[:api_key] = nil
    post_to_create_endpoint
    expect_unauthorised_error
  end

  it "should return 401 and JSON error array when it does not match an existing provider API key" do
    valid_params[:api_key] = SecureRandom.uuid
    post_to_create_endpoint
    expect_unauthorised_error
  end

  it "should return 401 and JSON error array when it is malformed" do
    valid_params[:api_key] = 'any-old-rubbish'
    post_to_create_endpoint
    expect_unauthorised_error
  end
end

shared_examples "should NOT be able to amend a non-draft claim" do
  context 'when claim is not a draft' do
    before(:each) { claim.submit! }

    it "should NOT be able to create #{described_class.to_s.split('::').last}" do
      post_to_create_endpoint
      expect(last_response.status).to eq 400
      expect_error_response("You cannot edit a claim that is not in draft state", 0)
    end
  end
end
