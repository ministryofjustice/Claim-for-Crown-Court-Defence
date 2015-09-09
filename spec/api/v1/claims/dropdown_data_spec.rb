require 'rails_helper'
require 'spec_helper'

describe API::V1::DropdownData do

  include Rack::Test::Methods

  CASE_TYPE_ENDPOINT          = "/api/case_types"
  COURT_ENDPOINT              = "/api/courts"
  ADVOCATE_CATEGORY_ENDPOINT  = "/api/advocate_categories"
  CRACKED_THIRD_ENDPOINT      = "/api/trial_cracked_at_thirds"
  GRANTING_BODY_ENDPOINT      = "/api/granting_body_types"
  OFFENCE_CLASS_ENDPOINT      = "api/offence_classes"
  OFFENCE_ENDPOINT            = "api/offences"
  FEE_CATEGORY_ENDPOINT       = "/api/fee_categories"
  FEE_TYPE_ENDPOINT           = "/api/fee_types"
  EXPENSE_TYPE_ENDPOINT       = "/api/expense_types"

  ALL_DROPDOWN_ENDPOINTS       = [CASE_TYPE_ENDPOINT, COURT_ENDPOINT, ADVOCATE_CATEGORY_ENDPOINT, CRACKED_THIRD_ENDPOINT, GRANTING_BODY_ENDPOINT, OFFENCE_CLASS_ENDPOINT, OFFENCE_ENDPOINT, FEE_CATEGORY_ENDPOINT, FEE_TYPE_ENDPOINT, EXPENSE_TYPE_ENDPOINT]
  FORBIDDEN_DROPDOWN_VERBS     = [:post, :put, :patch, :delete]

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
      create_list(:fee_category, 2)
      create_list(:fee_type, 2)
      create_list(:expense_type, 2)

      @endpoints_and_expectations = {
        CASE_TYPE_ENDPOINT => CaseType.all.to_json,
        COURT_ENDPOINT => Court.all.to_json,
        ADVOCATE_CATEGORY_ENDPOINT => Settings.advocate_categories.to_json,
        CRACKED_THIRD_ENDPOINT => Settings.trial_cracked_at_third.to_json,
        GRANTING_BODY_ENDPOINT => Settings.court_types.to_json,
        OFFENCE_CLASS_ENDPOINT => OffenceClass.all.to_json,
        OFFENCE_ENDPOINT => Offence.all.to_json,
        FEE_CATEGORY_ENDPOINT => FeeCategory.all.to_json,
        FEE_TYPE_ENDPOINT => FeeType.all.to_json,
        EXPENSE_TYPE_ENDPOINT => ExpenseType.all.to_json
      }

    }

    it 'should return a JSON formatted list of the required information' do
      @endpoints_and_expectations.each do |endpoint, expectation|
        response = get endpoint, format: :json
        expect(response.status).to eq 200
        expect(JSON.parse(response.body).count).to be > 0
        expect(JSON.parse(response.body)).to match_array JSON.parse(expectation)
      end
    end
  end


  context 'GET api/offences' do

      let!(:offence)                        { create(:offence) }
      let!(:other_offence)                  { create(:offence) }
      let!(:offence_with_same_description)  { create(:offence, description: offence.description) }
      let!(:response)                       { get OFFENCE_ENDPOINT }

    it 'should include the offence class as nested JSON' do
      body = JSON.parse(response.body)
      expect(body.first['offence_class']).to eq(JSON.parse(offence.offence_class.to_json))
    end

    it 'should only return offences matching description when offence_description param is present' do
      response = get OFFENCE_ENDPOINT, offence_description: offence.description
      returned_offences = JSON.parse(response.body)
      expect(returned_offences).to include(JSON.parse(offence.to_json), JSON.parse(offence_with_same_description.to_json))
      expect(returned_offences).to_not include(JSON.parse(other_offence.to_json))
      expect(returned_offences.count).to eql 2
    end
  end

  context 'GET api/fee_types/[:category]' do

    before {
      create(:fee_type, :basic, id: 1)
      create(:fee_type, :misc, id: 2)
      create(:fee_type, :fixed, id: 3)
    }

    def get_filtered_fee_types(category=nil)
      get FEE_TYPE_ENDPOINT, category: category, format: :json
    end

    it 'should filter by category' do
      categories = ['all', 'basic', 'misc', 'fixed']
      categories.each do |category|
        response = get_filtered_fee_types(category)
        expect(response.status).to eq 200
        expect(response.body).to eq FeeType.send(category).to_json
      end
    end

  end

end
