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

RSpec.shared_examples 'test setup' do
   describe 'test setup' do
    it 'vendor should belong to same provider as advocate' do
      expect(vendor.provider).to eql(advocate.provider)
    end
  end
end

RSpec.shared_examples 'a claim endpoint' do |options|
  context 'when sending non-permitted verbs' do
    ClaimApiEndpoints.for(options.fetch(:relative_endpoint)).all.each do |endpoint|
      context "to endpoint #{endpoint}" do
        ClaimApiEndpoints.forbidden_verbs.each do |api_verb|
          it "#{api_verb.upcase} returns a status of 405" do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end
end

RSpec.shared_examples 'an advocate claim validate endpoint' do |options|
  describe "POST #{ClaimApiEndpoints.for(options.fetch(:relative_endpoint)).validate}" do
    subject(:post_to_validate_endpoint) do
      post ClaimApiEndpoints.for(options.fetch(:relative_endpoint)).validate, valid_params, format: :json
    end

    include_examples "invalid API key validate endpoint"

    it 'valid request returns 200 and String true' do
      expect(vendor.provider).to eql(advocate.provider)
      post_to_validate_endpoint
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to eq({ "valid" => true })
    end

    it "returns 400 and JSON error array when creator email is invalid" do
      valid_params[:creator_email] = "non_existent_admin@bigblackhole.com"
      post_to_validate_endpoint
      expect_error_response("Creator email is invalid")
    end

    it "returns 400 and JSON error array when advocate email is invalid" do
      valid_params[:advocate_email] = "non_existent_advocate@bigblackhole.com"
      post_to_validate_endpoint
      expect_error_response("Advocate email is invalid")
    end

    it 'missing required params returns 400 and a JSON error array' do
      valid_params.delete(:case_number)
      post_to_validate_endpoint
      expect_error_response("Enter a case number")
    end
  end
end

RSpec.shared_examples 'an advocate claim create endpoint' do |options|
  describe "POST #{ClaimApiEndpoints.for(options.fetch(:relative_endpoint)).create}" do
    subject(:post_to_create_endpoint) do
      post ClaimApiEndpoints.for(options.fetch(:relative_endpoint)).create, valid_params, format: :json
    end

    context "when claim params are valid" do
      it "should create claim, return 201 and claim JSON output including UUID, but not API key" do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect(claim_class.active.find_by(uuid: json['id']).uuid).to eq(json['id'])
      end

      it "should exclude API key, creator email and advocate email from response" do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['api_key']).to be_nil
        expect(json['creator_email']).to be_nil
        expect(json['advocate_email']).to be_nil
      end

      it "should create one new claim" do
        expect { post_to_create_endpoint }.to change { claim_class.active.count }.by(1)
      end

      context "the new claim should" do
        let(:claim) { claim_class.active.last }

        before(:each) {
          post_to_create_endpoint
        }

        it "have the same attributes as described in params" do
          valid_params.each do |attribute, value|
            next if [:api_key, :creator_email, :advocate_email].include?(attribute) # because the saved claim record does not have these attribute
            valid_params[attribute] = value.to_date if claim.send(attribute).class.eql?(Date) # because the saved claim record has Date objects but the param has date strings
            expect(claim.send(attribute).to_s).to eq valid_params[attribute].to_s # some strings are converted to ints on save
          end
        end

        it "belong to the advocate whose email was specified in params" do
          expected_owner = User.find_by(email: valid_params[:advocate_email])
          expect(claim.external_user).to eq expected_owner.persona
        end
      end
    end

    context "when claim params are invalid" do
      include_examples "invalid API key create endpoint"

      context "invalid email input" do
        it "returns 400 and a JSON error array when advocate email is invalid" do
          valid_params[:advocate_email] = "non_existent_advocate@bigblackhole.com"
          post_to_create_endpoint
          expect_error_response("Advocate email is invalid")
        end

        it "returns 400 and a JSON error array when creator email is invalid" do
          valid_params[:creator_email] = "non_existent_creator@bigblackhole.com"
          post_to_create_endpoint
          expect_error_response("Creator email is invalid")
        end
      end

      context "missing expected params" do
        before { valid_params.delete(:case_number) }

        it "returns a JSON error array when required model attributes are missing" do
          post_to_create_endpoint
          expect_error_response("Enter a case number")
        end

        it "should not create a new claim" do
          expect{ post_to_create_endpoint }.not_to change { claim_class.active.count }
        end
      end

      context "existing but invalid value" do
        it "returns 400 and JSON error array of model validation BLANK errors" do
          valid_params[:court_id] = -1
          valid_params[:case_number] = -1
          post_to_create_endpoint
          expect_error_response("Choose a court", 0)
          expect_error_response("The case number must be in the format A20161234", 1)
        end

        it "returns 400 and JSON error array of model validation INVALID errors" do
          valid_params[:court_id] = nil
          valid_params[:case_number] = nil
          post_to_create_endpoint
          expect_error_response("Choose a court", 0)
          expect_error_response("Enter a case number", 1)
        end
      end

      context "unexpected error" do
        before do
          allow_any_instance_of(Claim::BaseClaim).to receive(:save!).and_raise(StandardError, 'my unexpected error')
        end

        it "returns 400 and JSON error array of error message" do
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          json = JSON.parse(last_response.body)
          expect_error_response("my unexpected error")
        end

        it "should not create a new claim" do
          expect{ post_to_create_endpoint }.not_to change { claim_class.active.count }
        end
      end
    end
  end
end

RSpec.shared_examples "fee validate endpoint" do
  it 'valid request returns 200 and String true' do
    post_to_validate_endpoint
    expect(last_response.status).to eq 200
    json = JSON.parse(last_response.body)
    expect(json).to eq({ "valid" => true })
  end

  it 'missing required params returns 400 and a JSON error array' do
    valid_params.delete(:fee_type_id)
    post_to_validate_endpoint
    expect(last_response.status).to eq 400
    expect(last_response.body).to eq(json_error_response)
  end

  it 'invalid claim id returns 400 and a JSON error array' do
    valid_params[:claim_id] = SecureRandom.uuid
    post_to_validate_endpoint
    expect(last_response.status).to eq 400
    expect(last_response.body).to eq "[{\"error\":\"Claim cannot be blank\"}]"
  end
end
