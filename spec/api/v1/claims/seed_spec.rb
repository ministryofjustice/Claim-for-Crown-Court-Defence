require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Seed do

  include Rack::Test::Methods

  CASE_TYPE_ENDPOINT      = "/api/seeds/case_types"
  COURT_ENDPOINT          = "/api/seeds/courts"
  ADVOCATE_CATEGORY_ENDPOINT  = "/api/seeds/advocate_categories"
  PROSECUTING_AUTHORITY_ENDPOINT  = "/api/seeds/prosecuting_authorities"
  CRACKED_THIRD_ENDPOINT  = "/api/seeds/trial_cracked_at_thirds"
  GRANTING_BODY_ENDPOINT  = "/api/seeds/granting_body_types"
  OFFENCE_CLASS_ENDPOINT  = "api/seeds/offence_classes"
  OFFENCE_ENDPOINT        = "api/seeds/offences"
  FEE_CATEGORY_ENDPOINT   = "/api/seeds/fee_categories"
  FEE_TYPE_ENDPOINT       = "/api/seeds/fee_types"
  EXPENSE_TYPE_ENDPOINT       = "/api/seeds/expense_types"

  context 'GET api/seeds/case_types' do

    it 'should return a status of 200' do
      response = get CASE_TYPE_ENDPOINT, format: :json
      expect(response.status).to eql 200
    end

    it 'should return a body of formatted JSON including guilty plea' do
      response = get CASE_TYPE_ENDPOINT, format: :json
      expect(JSON.parse(response.body)).to include('guilty_plea' )
    end

  end

  context 'GET api/seeds/courts' do

    before { create_list(:court,2) }
    let!(:court) { create(:court) }

    it 'should return a status of 200' do
      response = get COURT_ENDPOINT, format: :json
      expect(response.status).to eql 200
    end

    it 'should return JSON formatted list of fee categories' do
      response = get COURT_ENDPOINT, format: :json
      expected = JSON.parse(court.to_json)
      actual = JSON.parse(response.body)
      expect(actual).to include(expected)
      expect(actual.count).to eql 3
    end

  end

  context 'GET api/seeds/advocates_categories' do

    it 'should return a status of 200' do
      response = get ADVOCATE_CATEGORY_ENDPOINT, format: :json
      expect(response.status).to eql 200
    end

    it 'should return a bSON formatted list of advocate categories' do
      response = get ADVOCATE_CATEGORY_ENDPOINT, format: :json
      expect(JSON.parse(response.body)).to include('Leading junior')
    end

  end

  context 'GET api/seeds/prosecuting_authorities' do

    it 'should return a status of 200' do
      response = get PROSECUTING_AUTHORITY_ENDPOINT, format: :json
      expect(response.status).to eql 200
    end

    it 'should return a JSON formatted list of prosecuting authorities' do
      response = get PROSECUTING_AUTHORITY_ENDPOINT, format: :json
      expect(JSON.parse(response.body)).to include('cps' )
    end

  end

  context 'GET api/seeds/trial_cracked_at_thirds' do

     it 'should return a status of 200' do
      response = get CRACKED_THIRD_ENDPOINT, format: :json
      expect(response.status).to eql 200
    end

    it 'should return a JSON formatted list of cracked at thirds' do
      response = get CRACKED_THIRD_ENDPOINT, format: :json
      expect(JSON.parse(response.body)).to eql(['first_third','second_third','final_third'])
    end

  end

  context 'GET api/seeds/granting_body_types' do

    it 'should return a status of 200' do
      response = get GRANTING_BODY_ENDPOINT, format: :json
      expect(response.status).to eql 200
    end

    it 'should return a JSON formatted list of granting bodies' do
      response = get GRANTING_BODY_ENDPOINT, format: :json
      expect(JSON.parse(response.body)).to eql(["Magistrate's Court","Crown Court"])
    end

  end

  context 'GET api/seeds/offence_classes' do

    let!(:offence_class) { create(:offence_class) }

    def get_from_offence_classes_endpoint
      get OFFENCE_CLASS_ENDPOINT
    end

    it 'should return a status of 200' do
      response = get_from_offence_classes_endpoint
      expect(response.status).to eql 200
    end

    it 'should return JSON formatted list of Offence Classes' do
      response = get_from_offence_classes_endpoint
      expected = JSON.parse(offence_class.to_json)
      actual = JSON.parse(response.body)
      expect(actual).to include(expected)
      expect(actual.count).to eql 1
    end

  end

  context 'GET api/seeds/offences' do

    let!(:offence) { create(:offence) }

    def get_from_offences_endpoint
      get OFFENCE_ENDPOINT
    end

    it 'should return a status of 200' do
      response = get_from_offences_endpoint
      expect(response.status).to eql 200
    end

    it 'should return JSON formatted list of Offences' do
      response = get_from_offences_endpoint
      expected = JSON.parse(offence.to_json)
      actual = JSON.parse(response.body)
      expect(actual).to include(expected)
      expect(actual.count).to eql 1
    end

  end

  context 'GET api/seeds/fee_categories' do

    let!(:basic_category) { create(:basic_fee_category) }
    let!(:fixed_category) { create(:fixed_fee_category) }
    let!(:misc_category)  { create(:misc_fee_category) }

    def get_from_fee_category_endpoint
      get FEE_CATEGORY_ENDPOINT, format: :json
    end

    it 'should return a status of 200' do
      response = get_from_fee_category_endpoint
      expect(response.status).to eql 200
    end

    it 'should return JSON formatted list of fee categories' do
      response = get_from_fee_category_endpoint
      expected = JSON.parse(basic_category.to_json)
      actual = JSON.parse(response.body)
      expect(actual).to include(expected)
      expect(actual.count).to eql 3
    end

  end

  context 'GET api/seeds/fee_types/[:category]' do

    let!(:basic_fee_type) { create(:fee_type, :basic, id: 1) }
    let!(:misc_fee_type)  { create(:fee_type, :misc, id: 2) }
    let!(:fixed_fee_type) { create(:fee_type, :fixed, id: 3) }

    def get_from_fee_type_endpoint(category=nil)
      get FEE_TYPE_ENDPOINT, category, format: :json
    end

    it 'should return a status of 200' do
      response = get_from_fee_type_endpoint
      expect(response.status).to eql 200
    end

    it 'should return JSON formatted list of fee types' do
      response = get_from_fee_type_endpoint
      expected = JSON.parse(basic_fee_type.to_json)
      actual = JSON.parse(response.body)
      expect(actual).to include(expected)
      expect(actual.count).to eql 3
    end

    it 'should optionally filter on category' do
      params = { category: 'basic' }
      response = get_from_fee_type_endpoint(params)
      expect(JSON.parse(response.body).count).to eql 1
    end

  end

  context 'GET api/seeds/expense_types' do

    let!(:expense_type) { create(:expense_type, name: 'my example expense type') }

    it 'should return a status of 200' do
      response = get EXPENSE_TYPE_ENDPOINT, format: :json
      expect(response.status).to eql 200
    end

    it 'should return JSON formatted list of expense types' do
      response = get EXPENSE_TYPE_ENDPOINT, format: :json
      json_body = JSON.parse(response.body)
      expect(json_body).to include(JSON.parse(expense_type.to_json))
      expect(json_body.count).to eql 1
    end

  end

end
