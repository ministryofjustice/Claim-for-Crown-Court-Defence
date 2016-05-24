require 'rails_helper'
require 'spec_helper'
require_relative 'external_users/api_spec_helper'

describe API::V1::DropdownData do

  include Rack::Test::Methods
  include ApiSpecHelper

  CASE_TYPE_ENDPOINT          = "/api/case_types"
  COURT_ENDPOINT              = "/api/courts"
  ADVOCATE_CATEGORY_ENDPOINT  = "/api/advocate_categories"
  CRACKED_THIRD_ENDPOINT      = "/api/trial_cracked_at_thirds"
  OFFENCE_CLASS_ENDPOINT      = "/api/offence_classes"
  OFFENCE_ENDPOINT            = "/api/offences"
  FEE_TYPE_ENDPOINT           = "/api/fee_types"
  EXPENSE_TYPE_ENDPOINT       = "/api/expense_types"

  ALL_DROPDOWN_ENDPOINTS       = [CASE_TYPE_ENDPOINT, COURT_ENDPOINT, ADVOCATE_CATEGORY_ENDPOINT, CRACKED_THIRD_ENDPOINT, OFFENCE_CLASS_ENDPOINT, OFFENCE_ENDPOINT, FEE_TYPE_ENDPOINT, EXPENSE_TYPE_ENDPOINT]
  FORBIDDEN_DROPDOWN_VERBS     = [:post, :put, :patch, :delete]

  let(:provider) { create(:provider) }
  let(:params)   { {api_key: provider.api_key} }

  context 'when sending non-permitted verbs' do
    ALL_DROPDOWN_ENDPOINTS.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        FORBIDDEN_DROPDOWN_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it "#{api_verb.upcase} should return a status of 405" do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  context 'each dropdown data endpoint' do

    before {
      create_list(:case_type, 2)
      create_list(:court, 2)
      create_list(:offence_class, 2)
      create_list(:offence, 2)
      create_list(:misc_fee_type, 2)
      create_list(:expense_type, 2)

      @endpoints_and_expectations = {
        CASE_TYPE_ENDPOINT => CaseType.all.to_json,
        COURT_ENDPOINT => Court.all.to_json,
        ADVOCATE_CATEGORY_ENDPOINT => Settings.advocate_categories.to_json,
        CRACKED_THIRD_ENDPOINT => Settings.trial_cracked_at_third.to_json,
        OFFENCE_CLASS_ENDPOINT => OffenceClass.all.to_json,
        OFFENCE_ENDPOINT => Offence.all.to_json,
        FEE_TYPE_ENDPOINT => Fee::BaseFeeType.all.to_json
        # EXPENSE_TYPE_ENDPOINT => ExpenseType.all.to_json
      }
    }

    it 'should return a JSON formatted list of the required information' do
      @endpoints_and_expectations.each do |endpoint, expectation|
        response = get endpoint, params, format: :json
        expect(response.status).to eq 200
        expect(JSON.parse(response.body).count).to be > 0
        expect(JSON.parse(response.body)).to match_array JSON.parse(expectation)
      end
    end

    it 'should require an API key' do
      @endpoints_and_expectations.each do |endpoint, expectation|
        params.delete(:api_key)
        get endpoint, params, format: :json
        expect(last_response.status).to eq 401
        expect(last_response.body).to include('Unauthorised')
      end
    end
  end

  context 'GET api/offences' do

      let!(:offence)                        { create(:offence) }
      let!(:other_offence)                  { create(:offence) }
      let!(:offence_with_same_description)  { create(:offence, description: offence.description) }
      let!(:response)                       { get OFFENCE_ENDPOINT, params }

    it 'should include the offence class as nested JSON' do
      body = JSON.parse(response.body)
      expect(body.first['offence_class']).to eq(JSON.parse(offence.offence_class.to_json))
    end

    it 'should only return offences matching description when offence_description param is present' do
      params.merge!(offence_description: offence.description)
      response = get OFFENCE_ENDPOINT, params
      returned_offences = JSON.parse(response.body)
      expect(returned_offences).to include(JSON.parse(offence.to_json), JSON.parse(offence_with_same_description.to_json))
      expect(returned_offences).to_not include(JSON.parse(other_offence.to_json))
      expect(returned_offences.count).to eql 2
    end
  end

  context 'GET api/fee_types/[:category]' do

    before {
      create(:basic_fee_type, id: 1)
      create(:misc_fee_type, id: 2)
      create(:fixed_fee_type, id: 3)
    }

    def get_filtered_fee_types(category=nil)
      params.merge!(category: category)
      get FEE_TYPE_ENDPOINT, params , format: :json
    end

    it 'should filter by category' do
      categories = ['all', 'basic', 'misc', 'fixed']
      categories.each do |category|
        response = get_filtered_fee_types(category)
        expect(response.status).to eq 200
        expect(response.body).to eq Fee::BaseFeeType.send(category).to_json
      end
    end

  end

  context "expense v1" do
    let(:expectation) { ExpenseType.all.to_json }

    before(:each) do
      allow(Settings).to receive(:expense_schema_version).and_return(1)
      create_list(:expense_type, 2)
    end

    xit 'should return a JSON formatted list of the required information' do
      get EXPENSE_TYPE_ENDPOINT, params, format: :json
      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body).count).to be > 0
      expect(JSON.parse(last_response.body)).to match_array JSON.parse(expectation)
    end

    it 'should require an API key' do
      params.delete(:api_key)
      get EXPENSE_TYPE_ENDPOINT, params, format: :json
      expect(last_response.status).to eq 401
      expect(last_response.body).to include('Unauthorised')
    end

  end

  context "expense v2" do
    before do
      create_list(:expense_type, 2)
      get EXPENSE_TYPE_ENDPOINT, params, format: :json
    end

    context "with api key" do
      before do
        allow(Settings).to receive(:expense_schema_version).and_return(2)
      end

      let(:parsed_body) { JSON.parse(last_response.body) }

      it 'should return a JSON formatted list of the required information' do
        get EXPENSE_TYPE_ENDPOINT, params, format: :json
        expect(last_response.status).to eq 200
      end

      it "has 2 records" do
        get EXPENSE_TYPE_ENDPOINT, params, format: :json
        expect(parsed_body.count).to be == 2
      end

      it "has all the expected keys" do
        %w{ id name created_at updated_at roles reason_set reasons }.each do |key|
          expect(parsed_body.first).to have_key(key)
        end
      end

      it "has correct roles" do
        expect(parsed_body.first["roles"].size).to eq(2)
        expect(parsed_body.first["roles"]).to include("agfs")
        expect(parsed_body.first["roles"]).to include("lgfs")
      end

      it "has correct reasons structure" do
        expect(parsed_body.first["reasons"]).to be_an(Array)
        expect(parsed_body.first["reasons"].first).to have_key("id")
        expect(parsed_body.first["reasons"].first).to have_key("reason")
        expect(parsed_body.first["reasons"].first).to have_key("allow_explanatory_text")
      end
    end

    context "without api key" do
      let(:params) { {} }

      it 'should require an API key' do
        expect(last_response.status).to eq 401
        expect(last_response.body).to include('Unauthorised')
      end
    end
  end
end
