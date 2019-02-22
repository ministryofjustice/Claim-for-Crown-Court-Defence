RSpec.shared_examples "invalid API key validate endpoint" do |options|
  context 'with invalid API key' do
    it "returns 401 and JSON error array when it is not provided" do
      valid_params[:api_key] = nil
      post_to_validate_endpoint
      expect_unauthorised_error
    end

    it "returns 401 and JSON error array when it does not match an existing provider API key" do
      valid_params[:api_key] = SecureRandom.uuid
      post_to_validate_endpoint
      expect_unauthorised_error
    end

    it "returns 401 and JSON error array when it is malformed" do
      valid_params[:api_key] = 'any-old-rubbish'
      post_to_validate_endpoint
      expect_unauthorised_error
    end

    # TODO: it appears as though nested objects can be created on a claim by a
    # provider other than that which created the claim
    # - excluding for now
    unless [:other_provider].include? options&.fetch(:exclude)
      it "returns 401 and JSON error array when it is an API key from another provider's admin" do
        valid_params[:api_key] = other_provider.api_key
        post_to_validate_endpoint
        expect_unauthorised_error("Creator and advocate/litigator must belong to the provider")
      end
    end
  end
end

RSpec.shared_examples "invalid API key create endpoint" do |options|
  context 'with invalid API key' do
    it "returns 401 and JSON error array when it is not provided" do
      valid_params[:api_key] = nil
      post_to_create_endpoint
      expect_unauthorised_error
    end

    it "returns 401 and JSON error array when it does not match an existing provider API key" do
      valid_params[:api_key] = SecureRandom.uuid
      post_to_create_endpoint
      expect_unauthorised_error
    end

    it "returns 401 and JSON error array when it is malformed" do
      valid_params[:api_key] = 'any-old-rubbish'
      post_to_create_endpoint
      expect_unauthorised_error
    end

    # TODO: it appears as though nested objects can be created on a claim by a
    # provider other than that which created the claim
    # - excluding for now
    unless [:other_provider].include? options&.fetch(:exclude)
      it "returns 401 and JSON error array when it is an API key from another provider" do
        valid_params[:api_key] = other_provider.api_key
        post_to_create_endpoint
        expect_unauthorised_error("Creator and advocate/litigator must belong to the provider")
      end
    end
  end
end

RSpec.shared_examples "should NOT be able to amend a non-draft claim" do
  context 'when claim is not a draft' do
    before(:each) { claim.submit! }

    it "should NOT be able to create #{described_class.to_s.split('::').last}" do
      post_to_create_endpoint
      expect(last_response.status).to eq 400
      expect_error_response("You cannot edit a claim that is not in draft state",0)
    end
  end
end

RSpec.shared_examples "malformed or not iso8601 compliant dates" do |options|
  action = options[:action]
  options[:attributes].each do |attribute|
    it "returns 400 and JSON error when '#{attribute}' field is not in acceptable format" do
      valid_params[attribute] = '10-05-2015'
      action == :create ? post_to_create_endpoint : post_to_validate_endpoint
      expect_error_response("#{attribute} is not in an acceptable date format (YYYY-MM-DD[T00:00:00])")
    end
  end
end

RSpec.shared_examples "fee validate endpoint" do
  it 'valid requests should return 200 and String true' do
    post_to_validate_endpoint
    expect(last_response.status).to eq 200
    json = JSON.parse(last_response.body)
    expect(json).to eq({ "valid" => true })
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
    expect(last_response.body).to eq "[{\"error\":\"Claim cannot be blank\"}]"
  end
end
