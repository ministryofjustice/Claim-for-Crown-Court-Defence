RSpec.shared_examples 'invalid API key' do |options|
  let(:post_to_endpoint) { options[:action] == :create ? post_to_create_endpoint : post_to_validate_endpoint }
  let(:other_provider) { create(:provider) }

  context 'with invalid API key' do
    it 'response 401 and JSON error array when it is not provided' do
      valid_params[:api_key] = nil
      post_to_endpoint
      expect_unauthorised_error
    end

    it 'response 401 and JSON error array when it does not match an existing provider API key' do
      valid_params[:api_key] = SecureRandom.uuid
      post_to_endpoint
      expect_unauthorised_error
    end

    it 'response 401 and JSON error array when it is malformed' do
      valid_params[:api_key] = 'any-old-rubbish'
      post_to_endpoint
      expect_unauthorised_error
    end

    # TODO: it appears as though nested objects can be created on a claim by a
    # provider other than that which created the claim
    # - excluding for now
    unless [:other_provider].include? options&.fetch(:exclude)
      it 'response 401 and JSON error array when it is an API key from another provider' do
        valid_params[:api_key] = other_provider.api_key
        post_to_endpoint
        expect_unauthorised_error('Creator and advocate/litigator must belong to the provider')
      end
    end
  end
end

RSpec.shared_examples 'should NOT be able to amend a non-draft claim' do
  context 'when claim is not a draft' do
    before do
      claim.submit!
      post_to_create_endpoint
    end

    it { expect(last_response.status).to eq 400 }
    it { expect_error_response('You cannot edit a claim that is not in draft state') }
  end
end

RSpec.shared_examples 'malformed or not iso8601 compliant dates' do |options|
  subject(:post_to_validate_endpoint) do
    post options[:relative_endpoint], valid_params, format: :json
  end

  action = options[:action]
  options[:attributes].each do |attribute|
    it "response 400 and JSON error when '#{attribute}' field is not in acceptable format" do
      valid_params[attribute] = '10-05-2015'
      action == :create ? post_to_create_endpoint : post_to_validate_endpoint
      expect_error_response("#{attribute} is not in an acceptable date format (YYYY-MM-DD[T00:00:00])")
    end
  end
end

RSpec.shared_examples 'case_number validation' do
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

RSpec.shared_examples 'optional parameter validation' do |options|
  subject(:post_to_validate_endpoint) do
    post options[:relative_endpoint], valid_params, format: :json
  end

  it 'returns 200 when parameters that are optional are empty' do
    valid_params.except!(*options[:optional_parameters])
    post_to_validate_endpoint
    expect(last_response.status).to eq(200)
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
    ClaimApiEndpoints.for(options[:relative_endpoint]).all.each do |endpoint|
      context "with endpoint #{endpoint}" do
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
  describe "POST #{ClaimApiEndpoints.for(options[:relative_endpoint]).validate}" do
    subject(:post_to_validate_endpoint) do
      post ClaimApiEndpoints.for(options[:relative_endpoint]).validate, valid_params, format: :json
    end

    before { allow(LogStuff).to receive(:send) }

    let(:claim_user_type) do
      if ClaimApiEndpoints.for(options[:relative_endpoint]).validate
                          .match?(%r{/claims/(final|interim|transfer|hardship)})
        'Litigator'
      else
        'Advocate'
      end
    end

    include_examples 'invalid API key', exclude: nil, action: :validate
    include_examples 'case_number validation'

    context 'when request is valid' do
      before { post_to_validate_endpoint }

      it { expect(last_response.status).to eq(200) }
      it { expect(JSON.parse(last_response.body)['valid']).to be_truthy }
    end

    context 'when creator email is invalid' do
      before do
        valid_params[:creator_email] = 'non_existent_admin@bigblackhole.com'
        post_to_validate_endpoint
      end

      it { expect_error_response('Creator email is invalid') }
      it { expect(LogStuff).to have_received(:send).with(:error, hash_including(type: 'api-error')) }
    end

    context 'when user email is invalid' do
      before do
        valid_params[:user_email] = 'non_existent_user@bigblackhole.com'
        post_to_validate_endpoint
      end

      it { expect_error_response("#{claim_user_type} email is invalid") }
      it { expect(LogStuff).to have_received(:send).with(:error, hash_including(type: 'api-error')) }
    end

    context 'when user email is valid but contains upper case characters' do
      before do
        valid_params[:user_email].upcase!
        post_to_validate_endpoint
      end

      it { expect(last_response.status).to eq(200) }
      it { expect(JSON.parse(last_response.body)['valid']).to be_truthy }
    end

    context 'when required params are missing' do
      before do
        valid_params.delete(:case_number)
        post_to_validate_endpoint
      end

      it { expect_error_response('Enter a case number') }
      it { expect(LogStuff).to have_received(:send).with(:error, hash_including(type: 'api-error')) }
    end

    context 'when london_rates_apply is neither nil or boolean' do
      before do
        valid_params[:london_rates_apply] = 'Invalid string'
        post_to_validate_endpoint
      end

      it { expect_error_response('london_rates_apply is not in an acceptable format - choose true, false or nil') }
      it { expect(LogStuff).to have_received(:send).with(:error, hash_including(type: 'api-error')) }
    end
  end
end

RSpec.shared_examples 'a claim create endpoint' do |options|
  describe "POST #{ClaimApiEndpoints.for(options[:relative_endpoint]).create}" do
    subject(:post_to_create_endpoint) do
      post ClaimApiEndpoints.for(options[:relative_endpoint]).create, valid_params, format: :json
    end

    let(:claim_user_type) do
      if ClaimApiEndpoints.for(options[:relative_endpoint]).validate
                          .match?(%r{/claims/(final|interim|transfer|hardship)})
        'Litigator'
      else
        'Advocate'
      end
    end

    context 'when claim params are valid' do
      it 'creates a claim' do
        expect { post_to_create_endpoint }.to change { claim_class.active.count }.by(1)
      end

      it 'returns response status 201' do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
      end

      it 'returns the UUID of created claim' do
        post_to_create_endpoint
        json = JSON.parse(last_response.body)
        expect(claim_class.active.find_by(uuid: json['id']).uuid).to eq(json['id'])
      end

      it 'does not return the API key, creator email and user email from response' do
        post_to_create_endpoint
        expect(JSON.parse(last_response.body)['api_key']).to be_nil
      end

      it 'does not return the creator email' do
        post_to_create_endpoint
        expect(JSON.parse(last_response.body)['creator_email']).to be_nil
      end

      it 'does not return the user email' do
        post_to_create_endpoint
        expect(JSON.parse(last_response.body)['user_email']).to be_nil
      end

      context 'with the new claim' do
        let(:claim) { claim_class.active.last }

        before { post_to_create_endpoint }

        it 'has attributes matching the params' do
          # Attributes only used for authentication and authorisation: :api_key, :creator_email, :user_email
          # Attribute only used internally for adding case stage to hardship claims: :case_stage_unique_code
          valid_params.except(:api_key, :creator_email, :user_email, :case_stage_unique_code).each do |attribute, value|
            # The saved claim record has Date objects but the param has date strings
            valid_params[attribute] = value.to_date if claim.send(attribute).instance_of?(Date)
            expect(claim.send(attribute).to_s).to eq valid_params[attribute].to_s # some strings are converted to ints on save
          end
        end

        it 'belongs to the user whose email was specified in params' do
          expected_owner = User.find_by(email: valid_params[:user_email])
          expect(claim.external_user).to eq expected_owner.persona
        end

        it 'has had the London Rates Apply attribute correctly set' do
          expect(claim.london_rates_apply).to eq valid_params[:london_rates_apply]
        end
      end
    end

    context 'when claim params are invalid' do
      let(:email) { 'non_existent_user@bigblackhole.com' }

      include_examples 'invalid API key', exclude: nil, action: :create

      context 'when email input is invalid' do
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

      context 'when london_rates_apply is invalid' do
        it 'has had the London Rates Apply attribute correctly set' do
          valid_params[:london_rates_apply] = 'invalid string'
          post_to_create_endpoint
          expect_error_response('london_rates_apply is not in an acceptable format - choose true, false or nil')
        end
      end

      context 'when expected params are missing' do
        before { valid_params.delete(:case_number) }

        it 'response 400 and body JSON error array when required model attributes are missing' do
          post_to_create_endpoint
          expect_error_response('Enter a case number')
        end

        it 'does not create a new claim' do
          expect { post_to_create_endpoint }.not_to(change { claim_class.active.count })
        end
      end

      context 'when parameter is invalid' do
        before do
          valid_params[:court_id] = -1
          post_to_create_endpoint
        end

        it { expect_error_response('Choose a court') }
      end

      context 'when parameter is missing' do
        before do
          valid_params[:court_id] = nil
          post_to_create_endpoint
        end

        it { expect_error_response('Choose a court') }
      end

      context 'with an unexpected error' do
        before do
          allow_any_instance_of(Claim::BaseClaim).to receive(:save!).and_raise(StandardError, 'my unexpected error')
        end

        it 'returns the correct error message' do
          post_to_create_endpoint
          expect_error_response('my unexpected error')
        end

        it 'returns a 400 error' do
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
        end

        it 'does not create a new claim' do
          expect { post_to_create_endpoint }.not_to(change { claim_class.active.count })
        end
      end
    end
  end
end

RSpec.shared_examples 'fee validate endpoint' do
  context 'when the request is valid' do
    before { post_to_validate_endpoint }

    it { expect(last_response.status).to eq 200 }
    it { expect(JSON.parse(last_response.body)['valid']).to be_truthy }
  end

  context 'when required params are missing' do
    before do
      valid_params.delete(:fee_type_id)
      post_to_validate_endpoint
    end

    it { expect(last_response.status).to eq 400 }
    it { expect(last_response.body).to eq(json_error_response) }
    it { expect(LogStuff).to have_received(:send).with(:error, hash_including(type: 'api-error')) }
  end

  context 'with an invalid claim_id' do
    before do
      valid_params[:claim_id] = SecureRandom.uuid
      post_to_validate_endpoint
    end

    it { expect(last_response.status).to eq 400 }
    it { expect(last_response.body).to eq '[{"error":"Claim cannot be blank"}]' }
    it { expect(LogStuff).to have_received(:send).with(:error, hash_including(type: 'api-error')) }
  end
end
