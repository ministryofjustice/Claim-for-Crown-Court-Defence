RSpec.shared_context 'deactivate deprecation warnings' do
  before { allow(ActiveSupport::Deprecation).to receive(:warn) }
end

RSpec.shared_examples 'invalid API key validate endpoint' do |options|
  include_context 'deactivate deprecation warnings'

  context 'with invalid API key' do
    it 'response 401 and JSON error array when it is not provided' do
      valid_params[:api_key] = nil
      post_to_validate_endpoint
      expect_unauthorised_error
    end

    it 'response 401 and JSON error array when it does not match an existing provider API key' do
      valid_params[:api_key] = SecureRandom.uuid
      post_to_validate_endpoint
      expect_unauthorised_error
    end

    it 'response 401 and JSON error array when it is malformed' do
      valid_params[:api_key] = 'any-old-rubbish'
      post_to_validate_endpoint
      expect_unauthorised_error
    end

    # TODO: it appears as though nested objects can be created on a claim by a
    # provider other than that which created the claim
    # - excluding for now
    unless [:other_provider].include? options&.fetch(:exclude)
      it "response 401 and JSON error array when it is an API key from another provider's admin" do
        valid_params[:api_key] = other_provider.api_key
        post_to_validate_endpoint
        expect_unauthorised_error('Creator and advocate/litigator must belong to the provider')
      end
    end
  end
end

RSpec.shared_examples 'invalid API key create endpoint' do |options|
  include_context 'deactivate deprecation warnings'

  context 'with invalid API key' do
    it 'response 401 and JSON error array when it is not provided' do
      valid_params[:api_key] = nil
      post_to_create_endpoint
      expect_unauthorised_error
    end

    it 'response 401 and JSON error array when it does not match an existing provider API key' do
      valid_params[:api_key] = SecureRandom.uuid
      post_to_create_endpoint
      expect_unauthorised_error
    end

    it 'response 401 and JSON error array when it is malformed' do
      valid_params[:api_key] = 'any-old-rubbish'
      post_to_create_endpoint
      expect_unauthorised_error
    end

    # TODO: it appears as though nested objects can be created on a claim by a
    # provider other than that which created the claim
    # - excluding for now
    unless [:other_provider].include? options&.fetch(:exclude)
      it 'response 401 and JSON error array when it is an API key from another provider' do
        valid_params[:api_key] = other_provider.api_key
        post_to_create_endpoint
        expect_unauthorised_error('Creator and advocate/litigator must belong to the provider')
      end
    end
  end
end

RSpec.shared_examples 'should NOT be able to amend a non-draft claim' do
  include_context 'deactivate deprecation warnings'

  context 'when claim is not a draft' do
    before(:each) { claim.submit! }

    it "should NOT be able to create #{described_class.to_s.split('::').last}" do
      post_to_create_endpoint
      expect(last_response.status).to eq 400
      expect_error_response('You cannot edit a claim that is not in draft state',0)
    end
  end
end

RSpec.shared_examples 'malformed or not iso8601 compliant dates' do |options|
  action = options[:action]
  options[:attributes].each do |attribute|
    it "response 400 and JSON error when '#{attribute}' field is not in acceptable format" do
      valid_params[attribute] = '10-05-2015'
      action == :create ? post_to_create_endpoint : post_to_validate_endpoint
      expect_error_response("#{attribute} is not in an acceptable date format (YYYY-MM-DD[T00:00:00])")
    end
  end
end

RSpec.shared_examples 'advocate claim test setup' do
  describe 'test setup' do
    it 'vendor should belong to same provider as advocate' do
      expect(vendor.provider).to eql(advocate.provider)
    end
  end
end

RSpec.shared_examples 'litigator claim test setup' do
  describe 'test setup' do
    it 'vendor should belong to same provider as litigator' do
      expect(vendor.provider).to eql(litigator.provider)
    end
  end
end

RSpec.shared_examples 'a claim endpoint' do |options|
  context 'when sending non-permitted verbs' do
    ClaimApiEndpoints.for(options.fetch(:relative_endpoint)).all.each do |endpoint|
      context "to endpoint #{endpoint}" do
        ClaimApiEndpoints.forbidden_verbs.each do |api_verb|
          it "#{api_verb.upcase} response status of 405" do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end
end

RSpec.shared_examples 'a claim validate endpoint' do |options|
  include_context 'deactivate deprecation warnings'

  describe "POST #{ClaimApiEndpoints.for(options.fetch(:relative_endpoint)).validate}" do
    subject(:post_to_validate_endpoint) do
      post ClaimApiEndpoints.for(options.fetch(:relative_endpoint)).validate, valid_params, format: :json
    end

    let(:claim_user_type) do
      ClaimApiEndpoints.for(options.fetch(:relative_endpoint)).validate.match?(%r{/claims/(final|interim|transfer|hardship)}) ? 'Litigator' : 'Advocate'
    end

    include_examples 'invalid API key validate endpoint'

    it 'valid requests should return 200 and String true' do
      post_to_validate_endpoint
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to eq({ 'valid' => true })
    end

    it 'response 400 and JSON error array when creator email is invalid' do
      valid_params[:creator_email] = 'non_existent_admin@bigblackhole.com'
      post_to_validate_endpoint
      expect_error_response('Creator email is invalid')
    end

    it 'response 400 and JSON error array when user email is invalid' do
      valid_params[:user_email] = 'non_existent_user@bigblackhole.com'
      post_to_validate_endpoint
      expect_error_response("#{claim_user_type} email is invalid")
    end

    it 'response 400 and a JSON error array when missing required params' do
      valid_params.delete(:case_number)
      post_to_validate_endpoint
      expect_error_response('Enter a case number')
    end
  end
end

RSpec.shared_examples 'a claim create endpoint' do |options|
  include_context 'deactivate deprecation warnings'

  describe "POST #{ClaimApiEndpoints.for(options.fetch(:relative_endpoint)).create}" do
    subject(:post_to_create_endpoint) do
      post ClaimApiEndpoints.for(options.fetch(:relative_endpoint)).create, valid_params, format: :json
    end

    let(:claim_user_type) do
      ClaimApiEndpoints.for(options.fetch(:relative_endpoint)).validate.match?(%r{/claims/(final|interim|transfer|hardship)}) ? 'Litigator' : 'Advocate'
    end

    context 'when claim params are valid' do
      it 'creates a claim' do
        expect { post_to_create_endpoint }.to change { claim_class.active.count }.by(1)
      end

      it 'response status 201' do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
      end

      it 'response body JSON includes UUID of created claim' do
        post_to_create_endpoint
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect(claim_class.active.find_by(uuid: json['id']).uuid).to eq(json['id'])
      end

      it 'response body JSON excludes API key, creator email and user email from response' do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['api_key']).to be_nil
        expect(json['creator_email']).to be_nil
        expect(json['user_email']).to be_nil
      end

      context 'the new claim' do
        let(:claim) { claim_class.active.last }
        before { post_to_create_endpoint }

        it 'has attributes matching the params' do
          valid_params.each do |attribute, value|
            next if [:api_key, :creator_email, :user_email].include?(attribute) # because these are used for authentication and authorisation only
            next if [:case_stage_unique_code].include?(attribute) # used internally for adding case stage to hardship claims only
            valid_params[attribute] = value.to_date if claim.send(attribute).class.eql?(Date) # because the saved claim record has Date objects but the param has date strings
            expect(claim.send(attribute).to_s).to eq valid_params[attribute].to_s # some strings are converted to ints on save
          end
        end

        it 'belongs to the user whose email was specified in params' do
          expected_owner = User.find_by(email: valid_params[:user_email])
          expect(claim.external_user).to eq expected_owner.persona
        end
      end
    end

    context 'when claim params are invalid' do
      include_examples 'invalid API key create endpoint'

      let(:email) { 'non_existent_user@bigblackhole.com' }

      context 'invalid email input' do
        it 'response 400 and a JSON error array when user email is invalid' do
          valid_params[:user_email] = 'non_existent_user@bigblackhole.com'
          post_to_create_endpoint
          expect_error_response("#{claim_user_type} email is invalid")
        end

        it 'response 400 and a JSON error array when creator email is invalid' do
          valid_params[:creator_email] = email
          post_to_create_endpoint
          expect_error_response('Creator email is invalid')
        end
      end

      context 'missing expected params' do
        before { valid_params.delete(:case_number) }

        it 'response 400 and body JSON error array when required model attributes are missing' do
          post_to_create_endpoint
          expect_error_response('Enter a case number')
        end

        it 'should not create a new claim' do
          expect { post_to_create_endpoint }.not_to change { claim_class.active.count }
        end
      end

      context 'existing but invalid value' do
        it 'response 400 and JSON error array of model validation BLANK errors' do
          valid_params[:court_id] = -1
          post_to_create_endpoint
          expect_error_response('Choose a court', 0)
        end

        it 'response 400 and JSON error array of model validation INVALID errors' do
          valid_params[:court_id] = nil
          valid_params[:case_number] = nil
          post_to_create_endpoint
          expect_error_response('Choose a court', 0)
          expect_error_response('Enter a case number', 1)
        end
      end

      context 'invalid case number input' do
        it 'response 400 and JSON error array of model validation BLANK errors' do
          valid_params[:case_number] = -1
          post_to_create_endpoint
          expect_error_response('The case number must be a case number (e.g. A20161234) or unique reference number (less than 21 letters and numbers)', 0)
        end
      end

      context 'unexpected error' do
        before do
          allow_any_instance_of(Claim::BaseClaim).to receive(:save!).and_raise(StandardError, 'my unexpected error')
        end

        it 'response 400 and JSON error array of error message' do
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          json = JSON.parse(last_response.body)
          expect_error_response('my unexpected error')
        end

        it 'should not create a new claim' do
          expect { post_to_create_endpoint }.not_to change { claim_class.active.count }
        end
      end
    end
  end
end

RSpec.shared_examples 'a deprecated claim endpoint' do |options|
  include_context 'deactivate deprecation warnings'

  subject(:headers) do
    response = post ClaimApiEndpoints.for(options[:relative_endpoint]).send(options[:action]),
                    valid_params,
                    format: :json
    response.headers
  end

  context "on #{options[:relative_endpoint]} #{options[:action]}" do
    it 'response includes Sunset header ' do
      expect(headers['Sunset']).to eql options[:deprecation_datetime].httpdate
    end

    it 'response includes Sunset Link header to API release notes' do
      expect(headers['Link']).to eql '<http://example.org/api/release_notes>; rel="sunset";'
    end

    it 'logs a deprecation warning' do
      expect(ActiveSupport::Deprecation).to receive(:warn)
      subject
    end

    specify 'deprecation date not exceeded' do
      expect(Time.current).to be <= options[:deprecation_datetime], 'WARNING: deprecation date exceeded'
    end
  end
end

RSpec.shared_examples 'fee validate endpoint' do
  it 'valid request response 200 and String true' do
    post_to_validate_endpoint
    expect(last_response.status).to eq 200
    json = JSON.parse(last_response.body)
    expect(json).to eq({ 'valid' => true })
  end

  it 'missing required params response 400 and a JSON error array' do
    valid_params.delete(:fee_type_id)
    post_to_validate_endpoint
    expect(last_response.status).to eq 400
    expect(last_response.body).to eq(json_error_response)
  end

  it 'invalid claim id response 400 and a JSON error array' do
    valid_params[:claim_id] = SecureRandom.uuid
    post_to_validate_endpoint
    expect(last_response.status).to eq 400
    expect(last_response.body).to eq '[{"error":"Claim cannot be blank"}]'
  end
end
