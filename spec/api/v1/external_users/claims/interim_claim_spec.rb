require 'rails_helper'
require 'api_spec_helper'
require 'support/claim_api_endpoints'
require_relative '../shared_examples_for_all'

describe API::V1::ExternalUsers::Claims::InterimClaim do
  include DatabaseHousekeeping
  include Rack::Test::Methods
  include ApiSpecHelper

  let!(:provider)       { create(:provider, :lgfs) }
  let!(:other_provider) { create(:provider, :lgfs) }
  let!(:vendor)         { create(:external_user, :admin, provider: provider) }
  let!(:litigator)      { create(:external_user, :litigator, provider: provider) }
  let!(:other_vendor)   { create(:external_user, :admin, provider: other_provider) }
  let!(:offence)        { create(:offence, :miscellaneous)}
  let!(:court)          { create(:court)}
  let!(:valid_params)   { {
    :api_key => provider.api_key,
    :creator_email => vendor.user.email,
    :user_email => litigator.user.email,
    :supplier_number => provider.lgfs_supplier_numbers.first.supplier_number,
    :case_type_id => FactoryBot.create(:case_type, :trial).id,
    :case_number => 'A20161234',
    :offence_id => offence.id,
    :court_id => court.id,
  } }

  after(:all) { clean_database }

  describe 'vendor' do
    it 'should belong to same provider as litigator' do
      expect(vendor.provider).to eql(litigator.provider)
    end
  end

  context 'when sending non-permitted verbs' do
    ClaimApiEndpoints.for(:interim).all.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        ClaimApiEndpoints.forbidden_verbs.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it "#{api_verb.upcase} should return a status of 405" do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  context 'authentication / endpoint / user errors' do

    include_examples 'invalid API key validate endpoint'

    it 'should return 401 and JSON error array when it is an API key from another provider\'s admin' do
      valid_params[:api_key] = other_provider.api_key
      post_to_validate_endpoint
      expect_unauthorised_error('Creator and advocate/litigator must belong to the provider')
    end

    it 'should return 400 and JSON error array when creator email is invalid' do
      valid_params[:creator_email] = 'non_existent_admin@bigblackhole.com'
      post_to_validate_endpoint
      expect_error_response('Creator email is invalid')
    end

    it 'should return 400 and JSON error array when user email is invalid' do
      valid_params[:user_email] = 'non_existent_user@bigblackhole.com'
      post_to_validate_endpoint
      expect_error_response('Litigator email is invalid')
    end

    it 'missing required params should return 400 and a JSON error array' do
      valid_params.delete(:case_number)
      post_to_validate_endpoint
      expect_error_response('Enter a case number')
    end
  end

  describe 'POST api/external_users/claim/interim' do

    context 'valid parameters' do
      describe 'the newly created claim should ....' do
        it 'should have the same attributes as were submitted' do
          post_to_create_endpoint
          expect(last_response.status).to eq 201
          response_hash = JSON.parse( last_response.body)
          claim = Claim::InterimClaim.active.find_by(uuid: response_hash['id'])
          expect(claim).not_to be_nil, "Unable to locate claim with uuid #{response_hash['id']}"

          valid_params.each do |parameter_key, parameter_value|
            next if [:api_key, :creator_email, :user_email].include?(parameter_key) # because the saved claim record does not have these attribute
            expect(claim.__send__(parameter_key)).to eq parameter_value
          end
        end

        it 'should belong to the litigator whose email was specified in the params' do
          post_to_create_endpoint
          expect(last_response.status).to eq 201
          response_hash = JSON.parse( last_response.body)
          claim = Claim::InterimClaim.active.find_by(uuid: response_hash['id'])
          expect(claim).not_to be_nil, "Unable to locate claim with uuid #{response_hash['id']}"

          expected_owner = User.find_by(email: valid_params[:user_email])
          expect(claim.external_user).to eq expected_owner.persona
        end
      end
    end

    context 'invalid parameters' do

      context 'invalid email input' do
        it 'should return 400 and a JSON error array when user email is invalid' do
          valid_params[:user_email] = 'non_existent_user@bigblackhole.com'
          post_to_create_endpoint
          expect_error_response('Litigator email is invalid')
        end
        it 'should return 400 and a JSON error array when creator email is invalid' do
          valid_params[:creator_email] = 'non_existent_creator@bigblackhole.com'
          post_to_create_endpoint
          expect_error_response('Creator email is invalid')
        end
      end

      context 'missing expected params' do
        it 'should return a JSON error array when required model attributes are missing' do
          valid_params.delete(:case_type_id)
          valid_params.delete(:case_number)
          valid_params.delete(:case_concluded_at)
          post_to_create_endpoint
          expect_error_response('Choose a case type',0)
          expect_error_response('Enter a case number',1)
        end
      end

      context 'existing but invalid value' do
        it 'should return 400 and JSON error array of model validation BLANK errors' do
          valid_params[:case_type_id] = -1
          post_to_create_endpoint
          expect_error_response('Choose a case type',0)
        end

        it 'should return 400 and JSON error array of model validation INVALID errors' do
          valid_params[:case_number] = nil
          valid_params[:case_concluded_at] = 1.month.from_now.as_json
          post_to_create_endpoint
          expect_error_response('Enter a case number for example A20161234')
        end
      end

    context 'unexpected error' do
      it 'should return 400 and JSON error array of error message' do
        valid_params[:case_type_id] = 1000000000000000000000000000011111
        post_to_create_endpoint
        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect_error_response('out of range for ActiveModel::Type::Integer')
      end
    end

  end


  end


  def post_to_create_endpoint
    post ClaimApiEndpoints.for(:interim).create, valid_params, format: :json
  end


  def post_to_validate_endpoint
    post ClaimApiEndpoints.for(:interim).validate, valid_params, format: :json
  end


end

