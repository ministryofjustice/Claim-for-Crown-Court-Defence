require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Seed do

  include Rack::Test::Methods

  FEE_TYPE_ENDPOINT       = "/api/seeds/fee_types"
  OFFENCE_CLASS_ENDPOINT  = "api/seeds/offence_classes"
  OFFENCE_ENDPOINT        = "api/seeds/offences"


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

    it 'should return JSON formatted list of fee_types' do
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

end
