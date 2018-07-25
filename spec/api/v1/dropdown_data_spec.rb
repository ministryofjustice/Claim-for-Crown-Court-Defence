require 'rails_helper'
require 'api_spec_helper'

RSpec.describe API::V1::DropdownData do
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
  EXPENSE_REASONS_ENDPOINT    = "/api/expense_reasons"
  DISBURSEMENT_TYPE_ENDPOINT  = "/api/disbursement_types"
  TRANSFER_STAGES_ENDPOINT    = "/api/transfer_stages"
  TRANSFER_CASE_CONCLUSIONS_ENDPOINT = "/api/transfer_case_conclusions"

  FORBIDDEN_DROPDOWN_VERBS = [:post, :put, :patch, :delete]
  ALL_DROPDOWN_ENDPOINTS = [
      CASE_TYPE_ENDPOINT,
      COURT_ENDPOINT,
      ADVOCATE_CATEGORY_ENDPOINT,
      CRACKED_THIRD_ENDPOINT,
      OFFENCE_CLASS_ENDPOINT,
      OFFENCE_ENDPOINT,
      FEE_TYPE_ENDPOINT,
      EXPENSE_TYPE_ENDPOINT,
      EXPENSE_REASONS_ENDPOINT,
      DISBURSEMENT_TYPE_ENDPOINT,
      TRANSFER_STAGES_ENDPOINT,
      TRANSFER_CASE_CONCLUSIONS_ENDPOINT
  ]

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

    let(:results) do
      {
        CASE_TYPE_ENDPOINT => API::Entities::CaseType.represent(CaseType.all).to_json,
        COURT_ENDPOINT => API::Entities::Court.represent(Court.all).to_json,
        ADVOCATE_CATEGORY_ENDPOINT => Settings.advocate_categories.to_json,
        CRACKED_THIRD_ENDPOINT => Settings.trial_cracked_at_third.to_json,
        OFFENCE_CLASS_ENDPOINT => API::Entities::OffenceClass.represent(OffenceClass.all).to_json,
        OFFENCE_ENDPOINT => API::Entities::Offence.represent(FeeScheme.nine.agfs.first.offences).to_json,
        FEE_TYPE_ENDPOINT => API::Entities::BaseFeeType.represent(Fee::BaseFeeType.all).to_json,
        EXPENSE_TYPE_ENDPOINT => API::Entities::ExpenseType.represent(ExpenseType.all).to_json,
        EXPENSE_REASONS_ENDPOINT => API::Entities::ExpenseReasonSet.represent(ExpenseType.reason_sets).to_json,
        DISBURSEMENT_TYPE_ENDPOINT => API::Entities::DisbursementType.represent(DisbursementType.active).to_json,
        TRANSFER_STAGES_ENDPOINT => API::Entities::SimpleKeyValueList.represent(Claim::TransferBrain::TRANSFER_STAGES.to_a).to_json,
        TRANSFER_CASE_CONCLUSIONS_ENDPOINT => API::Entities::SimpleKeyValueList.represent(Claim::TransferBrain::CASE_CONCLUSIONS.to_a).to_json
      }
    end

    before do
      create_list(:case_type, 2)
      create_list(:court, 2)
      create_list(:offence_class, 2, :with_lgfs_offence)
      create_list(:offence, 2, :with_fee_scheme)
      create_list(:offence, 2, :with_fee_scheme_ten)
      create_list(:basic_fee_type, 2)
      create_list(:expense_type, 2)
      create_list(:disbursement_type, 2)
    end

    it "should return a JSON formatted list of the required information" do
      results.each do |endpoint, json|
        response = get endpoint, params, format: :json
        expect(response.status).to eq 200
        expect(JSON.parse(response.body).count).to be > 0
        expect(JSON.parse(response.body)).to match_array JSON.parse(json)
      end
    end

    it 'should require an API key' do
      results.each do |endpoint, expectation|
        params.delete(:api_key)
        get endpoint, params, format: :json
        expect(last_response.status).to eq 401
        expect(last_response.body).to include('Unauthorised')
      end
    end

    it 'should return 406 Not Acceptable if requested API version via header is not supported' do
      header 'Accept-Version', 'v2'

      results.each do |endpoint, _|
        get endpoint, params, format: :json
        expect(last_response.status).to eq 406
        expect(last_response.body).to include('The requested version is not supported.')
      end
    end
  end

  context 'GET api/offences' do

    let!(:fee_scheme) { create(:fee_scheme, :agfs_nine) }
    let!(:offence)                        { create(:offence) }
    let!(:other_offence)                  { create(:offence) }
    let!(:misc_offence)                   { create(:offence, :miscellaneous, offence_class: offence.offence_class) }
    let!(:offence_with_same_description)  { create(:offence, description: offence.description) }
    let(:exposed_offence_class) { ->(offence_class) { API::Entities::OffenceClass.represent(offence_class).as_json } }
    let(:exposed_offence) { ->(offence) { API::Entities::Offence.represent(offence).as_json } }

    before do
      create :offence_fee_scheme, offence: offence, fee_scheme: fee_scheme
      create :offence_fee_scheme, offence: other_offence, fee_scheme: fee_scheme
      create :offence_fee_scheme, offence: offence_with_same_description, fee_scheme: fee_scheme
    end

    it 'should include the offence class as nested JSON' do
      response = get OFFENCE_ENDPOINT, params
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body.first[:offence_class]).to eq(exposed_offence_class[offence.offence_class])
    end

    it 'should only return offences matching description when offence_description param is present' do
      params.merge!(offence_description: offence.description)
      response = get OFFENCE_ENDPOINT, params

      returned_offences = JSON.parse(response.body, symbolize_names: true)
      expect(returned_offences).to include(exposed_offence[offence], exposed_offence[offence_with_same_description])
      expect(returned_offences).to_not include(exposed_offence[other_offence])
      expect(returned_offences.count).to eql 2
    end
  end

  context 'GET api/fee_types/[:category]' do
    before {
      create(:basic_fee_type, :agfs_scheme_9, id: 1)
      create(:misc_fee_type, id: 2)
      create(:fixed_fee_type, :agfs_scheme_9, id: 3)
      create(:graduated_fee_type, id: 4) # LGFS fee, not applicable to AGFS
      create(:basic_fee_type, :agfs_scheme_10, id: 5)
      create(:misc_fee_type, :agfs_scheme_10, id: 6)
      create(:fixed_fee_type, :agfs_all_schemes, id: 7)
    }

    def get_filtered_fee_types(category=nil)
      params.merge!(category: category)
      get FEE_TYPE_ENDPOINT, params, format: :json
    end

    it 'should filter by category and scheme applicability' do
      categories = %w(basic misc fixed)
      categories.each do |category|
        response = get_filtered_fee_types(category)
        expect(response.status).to eq 200
        expect(response.body).to eq API::Entities::BaseFeeType.represent(Fee::BaseFeeType.send(category).agfs).to_json
      end
    end

    context 'with role filter' do
      let(:parsed_body) { JSON.parse(last_response.body) }

      it 'should only include AGFS fee types' do
        get FEE_TYPE_ENDPOINT, params.merge(role: 'agfs_scheme_9'), format: :json
        expect(parsed_body.collect{|e| e['roles'].include?('agfs_scheme_9') }.uniq).to eq([true])
      end

      it 'should only include LGFS fee types' do
        get FEE_TYPE_ENDPOINT, params.merge(role: 'lgfs'), format: :json
        expect(parsed_body.collect{|e| e['roles'].include?('lgfs') }.uniq).to eq([true])
      end

      context 'fixed fees for' do
        before { get FEE_TYPE_ENDPOINT, params.merge(category: 'fixed', role: role), format: :json }

        context 'agfs' do
          let(:role) { 'agfs' }

          it 'returns scheme 9 agfs roles' do
            expect(parsed_body.pluck('id')).to match_array([3, 7])
          end
        end

        context 'agfs_scheme_9' do
          let(:role) { 'agfs_scheme_9' }

          it 'returns scheme 9 agfs roles' do
            expect(parsed_body.pluck('id')).to match_array([3, 7])
          end
        end

        context 'agfs_scheme_10' do
          let(:role) { 'agfs_scheme_10' }

          it 'returns scheme 10 agfs roles' do
            expect(parsed_body.pluck('id')).to eq([7])
          end
        end
      end
    end
  end

  context 'GET api/advocate_categories[:category]' do
    before do
      allow(Settings).to receive(:agfs_reform_advocate_categories).and_return(['QC', 'Leading junior', 'Junior'])
      allow(Settings).to receive(:advocate_categories).and_return(['QC', 'Led junior', 'Leading junior', 'Junior'])
      params.merge!(role: role)
      get ADVOCATE_CATEGORY_ENDPOINT, params, format: :json
    end

    context 'when role is nil' do
      let(:role) { nil }

      it 'returns 4 options' do
        expect(JSON.parse(last_response.body).count).to eq 4
      end
    end

    context 'when role is agfs' do
      let(:role) { 'agfs' }

      it 'returns 4 options' do
        expect(JSON.parse(last_response.body).count).to eq 4
      end
    end

    context 'when role is agfs_scheme_9' do
      let(:role) { 'agfs_scheme_9' }

      it 'returns 4 options' do
        expect(JSON.parse(last_response.body).count).to eq 4
      end
    end

    context 'when role is agfs_scheme_10' do
      let(:role) { 'agfs_scheme_10' }

      it 'returns 3 options' do
        expect(JSON.parse(last_response.body).count).to eq 3
      end
    end

    context 'when role is lgfs' do
      let(:role) { 'lgfs' }

      it 'returns 4 options' do
        expect(JSON.parse(last_response.body).count).to eq 4
      end
    end
  end

  context "expense v2" do
    before do
      create_list(:expense_type, 2)
      create(:expense_type,:lgfs)
      get EXPENSE_TYPE_ENDPOINT, params, format: :json
    end

    context "with api key" do
      let(:parsed_body) { JSON.parse(last_response.body) }

      it 'should return a JSON formatted list of the required information' do
        get EXPENSE_TYPE_ENDPOINT, params, format: :json
        expect(last_response.status).to eq 200
      end

      context 'with role filter' do
        it 'should only include AGFS scheme 9 expense types' do
          get EXPENSE_TYPE_ENDPOINT, params.merge(role: 'agfs'), format: :json
          expect(parsed_body.collect{|e| e['roles'].include?('agfs') }.uniq).to eq([true])
        end

        it 'should only include LGFS expense types' do
          get EXPENSE_TYPE_ENDPOINT, params.merge(role: 'lgfs'), format: :json
          expect(parsed_body.collect{|e| e['roles'].include?('lgfs') }.uniq).to eq([true])
        end
      end

      it "has all the expected keys" do
        %w{ id name roles reason_set }.each do |key|
          expect(parsed_body.first).to have_key(key)
        end
      end

      it "has correct roles" do
        expect(parsed_body.first["roles"].size).to eq(2)
        expect(parsed_body.first["roles"]).to include("agfs")
        expect(parsed_body.first["roles"]).to include("lgfs")
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
