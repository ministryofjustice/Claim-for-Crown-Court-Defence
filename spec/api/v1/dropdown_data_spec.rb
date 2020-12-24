require 'rails_helper'

RSpec.describe API::V1::DropdownData do
  include Rack::Test::Methods
  include ApiSpecHelper

  CASE_TYPE_ENDPOINT                  = '/api/case_types'
  COURT_ENDPOINT                      = '/api/courts'
  ADVOCATE_CATEGORY_ENDPOINT          = '/api/advocate_categories'
  CRACKED_THIRD_ENDPOINT              = '/api/trial_cracked_at_thirds'
  OFFENCE_CLASS_ENDPOINT              = '/api/offence_classes'
  OFFENCE_ENDPOINT                    = '/api/offences'
  FEE_TYPE_ENDPOINT                   = '/api/fee_types'
  EXPENSE_TYPE_ENDPOINT               = '/api/expense_types'
  EXPENSE_REASONS_ENDPOINT            = '/api/expense_reasons'
  DISBURSEMENT_TYPE_ENDPOINT          = '/api/disbursement_types'
  TRANSFER_STAGES_ENDPOINT            = '/api/transfer_stages'
  TRANSFER_CASE_CONCLUSIONS_ENDPOINT  = '/api/transfer_case_conclusions'
  CASE_STAGE_ENDPOINT                 = '/api/case_stages'

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
    TRANSFER_CASE_CONCLUSIONS_ENDPOINT,
    CASE_STAGE_ENDPOINT
  ]

  let(:provider) { create(:provider) }
  let(:params) { { api_key: provider.api_key } }

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
        TRANSFER_CASE_CONCLUSIONS_ENDPOINT => API::Entities::SimpleKeyValueList.represent(Claim::TransferBrain::CASE_CONCLUSIONS.to_a).to_json,
        CASE_STAGE_ENDPOINT => API::Entities::CaseStage.represent(CaseStage.active.all).to_json
      }
    end

    before do
      seed_fee_schemes
      seed_case_types
      seed_case_stages
      create_list(:court, 2)
      create_list(:offence_class, 2, :with_lgfs_offence)
      create_list(:offence, 2, :with_fee_scheme_nine)
      create_list(:offence, 2, :with_fee_scheme_ten)
      create_list(:basic_fee_type, 2)
      create_list(:expense_type, 2)
      create_list(:disbursement_type, 2)
    end

    it 'should return a JSON formatted list of the required information' do
      results.each do |endpoint, json|
        response = get endpoint, params, format: :json
        expect(response.status).to eq 200
        expect(response.body).to be_json_eql(json)
      end
    end

    it 'should require an API key' do
      results.each do |endpoint, _|
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
    subject(:returned_offences) do
      response = get OFFENCE_ENDPOINT, params
      JSON.parse(response.body, symbolize_names: true)
    end

    before do
      seed_fee_schemes
    end

    let!(:scheme_9_offence) { create(:offence, :with_fee_scheme_nine) }
    let!(:scheme_10_offence) { create(:offence, :with_fee_scheme_ten) }
    let!(:scheme_11_offence) { create(:offence, :with_fee_scheme_eleven) }
    let(:exposed_offence) { ->(offence) { API::Entities::Offence.represent(offence).as_json } }

    context 'filtering' do
      context 'by rep order date' do
        context 'using a scheme 9 date' do
          it 'defaults to scheme 9 offences' do
            is_expected.to match_array([exposed_offence[scheme_9_offence]])
          end

          it 'returns scheme 9 offences' do
            params.merge!(rep_order_date: '2016-03-01')
            is_expected.to match_array([exposed_offence[scheme_9_offence]])
          end
        end

        context 'using a scheme 10 date' do
          it 'returns scheme 10 offences' do
            params.merge!(rep_order_date: '2018-04-01')
            is_expected.to match_array([exposed_offence[scheme_10_offence]])
          end
        end

        context 'using a scheme 11 date' do
          it 'returns scheme 11 offences' do
            params.merge!(rep_order_date: '2018-12-31')
            is_expected.to match_array([exposed_offence[scheme_11_offence]])
          end
        end
      end

      context 'by description' do
        let!(:offence_with_same_description) { create(:offence, :with_fee_scheme_nine, description: scheme_9_offence.description) }

        it 'returns offences matching description' do
          params.merge!(offence_description: scheme_9_offence.description)
          is_expected.to match_array([exposed_offence[scheme_9_offence], exposed_offence[offence_with_same_description]])
        end
      end

      context 'by unique_code' do
        context 'scheme 9' do
          let(:rep_order_date) { scheme_date_for('scheme 9') }

          it 'returns matching offence' do
            params.merge!(rep_order_date: rep_order_date, unique_code: scheme_9_offence.unique_code)
            is_expected.to match_array([exposed_offence[scheme_9_offence]])
          end
        end

        context 'scheme 10' do
          let(:rep_order_date) { scheme_date_for('scheme 10') }

          it 'returns matching offence' do
            params.merge!(rep_order_date: rep_order_date, unique_code: scheme_10_offence.unique_code)
            is_expected.to match_array([exposed_offence[scheme_10_offence]])
          end
        end

        context 'scheme 11' do
          let(:rep_order_date) { scheme_date_for('scheme 11') }

          it 'returns matching offence' do
            params.merge!(rep_order_date: rep_order_date, unique_code: scheme_11_offence.unique_code)
            is_expected.to match_array([exposed_offence[scheme_11_offence]])
          end
        end
      end
    end
  end

  context 'GET api/fee_types/[:category]' do
    before {
      create(:basic_fee_type, :agfs_scheme_9)
      create(:misc_fee_type, :agfs_scheme_9)
      create(:fixed_fee_type, :agfs_scheme_9)

      create(:basic_fee_type, :agfs_scheme_10)
      create(:fixed_fee_type, :agfs_scheme_10)
      create(:misc_fee_type, :agfs_scheme_10)

      create(:basic_fee_type, :agfs_scheme_12)
      create(:fixed_fee_type, :agfs_scheme_12)
      create(:misc_fee_type, :agfs_scheme_12)

      create(:basic_fee_type, :agfs_all_schemes)
      create(:fixed_fee_type, :agfs_all_schemes)
      create(:misc_fee_type, :agfs_all_schemes)

      create(:graduated_fee_type) # LGFS fee, not applicable to AGFS
    }

    %w(all basic misc fixed graduated interim transfer warrant).each do |cat|
      context "with category filter: #{cat}" do
        before { get FEE_TYPE_ENDPOINT, params.merge(category: cat), format: :json }

        it { expect(last_response.status).to eq 200 }
      end
    end

    context 'with category filter' do
      before { get FEE_TYPE_ENDPOINT, params.merge(category: category), format: :json }

      let(:parsed_body) { JSON.parse(last_response.body) }

      context 'with all' do
        let(:category) { 'all' }

        it 'returns all fee types' do
          expect(parsed_body.pluck('type').uniq).to \
            match_array(['Fee::BasicFeeType','Fee::FixedFeeType','Fee::MiscFeeType', 'Fee::GraduatedFeeType'])
        end
      end

      context 'with basic' do
        let(:category) { 'basic' }

        it 'returns basic fee types only' do
          expect(parsed_body.pluck('type')).to all(eql('Fee::BasicFeeType'))
        end
      end

      context 'with fixed' do
        let(:category) { 'fixed' }

        it 'returns fixed fee types only' do
          expect(parsed_body.pluck('type')).to all(eql('Fee::FixedFeeType'))
        end
      end

      context 'with misc' do
        let(:category) { 'misc' }

        it 'returns misc fee types only' do
          expect(parsed_body.pluck('type')).to all(eql('Fee::MiscFeeType'))
        end
      end
    end

    context 'with role filter' do
      let(:parsed_body) { JSON.parse(last_response.body) }

      it 'should only include AGFS scheme 9 fee types' do
        get FEE_TYPE_ENDPOINT, params.merge(role: 'agfs_scheme_9'), format: :json
        expect(parsed_body.pluck('roles')).to all(include('agfs_scheme_9'))
      end

      it 'should only include AGFS scheme 10 fee types' do
        get FEE_TYPE_ENDPOINT, params.merge(role: 'agfs_scheme_10'), format: :json
        expect(parsed_body.pluck('roles')).to all(include('agfs_scheme_10'))
      end

      it 'should only include AGFS scheme 12 fee types' do
        get FEE_TYPE_ENDPOINT, params.merge(role: 'agfs_scheme_12'), format: :json
        expect(parsed_body.pluck('roles')).to all(include('agfs_scheme_12'))
      end

      it 'should only include LGFS fee types' do
        get FEE_TYPE_ENDPOINT, params.merge(role: 'lgfs'), format: :json
        expect(parsed_body.pluck('roles')).to all(include('lgfs'))
      end

      context 'when fixed category specified' do
        before { get FEE_TYPE_ENDPOINT, params.merge(category: 'fixed', role: role), format: :json }

        context 'with agfs role' do
          let(:role) { 'agfs' }

          it 'returns fixed fee types only' do
            expect(parsed_body.pluck('type')).to all(eql('Fee::FixedFeeType'))
          end

          it 'returns agfs fee types only' do
            expect(parsed_body.pluck('roles')).to all(include('agfs'))
          end
        end

        context 'with agfs_scheme_9 role' do
          let(:role) { 'agfs_scheme_9' }

          it 'returns fixed fee types only' do
            expect(parsed_body.pluck('type')).to all(eql('Fee::FixedFeeType'))
          end

          it 'returns agfs scheme 9 fee types only' do
            expect(parsed_body.pluck('roles')).to all(include('agfs_scheme_9'))
          end
        end

        context 'with agfs_scheme_10 role' do
          let(:role) { 'agfs_scheme_10' }

          it 'returns fixed fee types only' do
            expect(parsed_body.pluck('type')).to all(eql('Fee::FixedFeeType'))
          end

          it 'returns agfs scheme 10 fee types only' do
            expect(parsed_body.pluck('roles')).to all(include('agfs_scheme_10'))
          end
        end

        context 'with agfs_scheme_12 role' do
          let(:role) { 'agfs_scheme_12' }

          it 'returns fixed fee types only' do
            expect(parsed_body.pluck('type')).to all(eql('Fee::FixedFeeType'))
          end

          it 'returns agfs scheme 12 fee types only' do
            expect(parsed_body.pluck('roles')).to all(include('agfs_scheme_12'))
          end
        end
      end
    end

    context 'with unique code filter' do
      subject(:response_body) do
        response = get FEE_TYPE_ENDPOINT, params.merge(unique_code: unique_code), format: :json
        response.body
      end

      before { create(:misc_fee_type, :midth) }

      context 'when unique_code exists' do
        let(:unique_code) { 'MIDTH' }
        it 'returns a specific fee type' do
          is_expected.to have_json_size 1
          is_expected.to be_json_eql('Confiscation hearings (half day)'.to_json).at_path('0/description')
        end
      end

      context 'when unique_code does not exist' do
        let(:unique_code) { 'MODTH' }
        it 'returns nil' do
          is_expected.to have_json_size 0
        end
      end

      context 'when unique_code is nil' do
        let(:unique_code) { nil }
        it 'returns all' do
          expect(JSON.parse(response_body).size).to be > 1
        end
      end

      context 'when unique_code is empty string' do
        let(:unique_code) { '' }
        it 'returns all' do
          expect(JSON.parse(response_body).size).to be > 1
        end
      end
    end
  end

  context 'GET api/advocate_categories[:category]' do
    before do
      params.merge!(role: role)
      get ADVOCATE_CATEGORY_ENDPOINT, params, format: :json
    end

    let(:parsed_response) { JSON.parse(last_response.body) }

    shared_examples 'returns agfs scheme 9 advocate categories' do
      let(:agfs_scheme_9_advocate_categories) { ['QC', 'Led junior', 'Leading junior', 'Junior alone'] }

      it 'returns agfs scheme 9 advocate categories' do
        expect(parsed_response).to match_array(agfs_scheme_9_advocate_categories)
      end
    end

    shared_examples 'returns agfs scheme 10+ advocate categories' do
      let(:agfs_scheme_10_plus_advocate_categories) { ['QC', 'Leading junior', 'Junior'] }

      it 'returns agfs scheme 10+ advocate categories' do
        expect(parsed_response).to match_array(agfs_scheme_10_plus_advocate_categories)
      end
    end

    context 'when role is nil' do
      let(:role) { nil }

      include_examples 'returns agfs scheme 9 advocate categories'
    end

    context 'when role is invalid' do
      let(:role) { :non_existent_role }

      it 'returns error' do
        expect(parsed_response.first).to have_key('error')
      end

      it 'returns error message' do
        expect(parsed_response.first['error']).to match(/not.*valid/)
      end
    end

    context 'when role is agfs' do
      let(:role) { 'agfs' }

      include_examples 'returns agfs scheme 9 advocate categories'
    end

    context 'when role is agfs_scheme_9' do
      let(:role) { 'agfs_scheme_9' }

      include_examples 'returns agfs scheme 9 advocate categories'
    end

    context 'when role is agfs_scheme_10' do
      let(:role) { 'agfs_scheme_10' }

      include_examples 'returns agfs scheme 10+ advocate categories'
    end

    context 'when role is agfs_scheme_12' do
      let(:role) { 'agfs_scheme_12' }

      include_examples 'returns agfs scheme 10+ advocate categories'
    end

    context 'when role is lgfs' do
      let(:role) { 'lgfs' }

      it 'returns no advocate categories' do
        expect(parsed_response).to be_empty
      end
    end
  end

  context 'expense v2' do
    before do
      create_list(:expense_type, 2)
      create(:expense_type,:lgfs)
      get EXPENSE_TYPE_ENDPOINT, params, format: :json
    end

    context 'with api key' do
      let(:parsed_body) { JSON.parse(last_response.body) }

      it 'should return a JSON formatted list of the required information' do
        get EXPENSE_TYPE_ENDPOINT, params, format: :json
        expect(last_response.status).to eq 200
      end

      context 'with role filter' do
        it 'should only include AGFS scheme 9 expense types' do
          get EXPENSE_TYPE_ENDPOINT, params.merge(role: 'agfs'), format: :json
          expect(parsed_body.collect { |e| e['roles'].include?('agfs') }.uniq).to eq([true])
        end

        it 'should only include LGFS expense types' do
          get EXPENSE_TYPE_ENDPOINT, params.merge(role: 'lgfs'), format: :json
          expect(parsed_body.collect { |e| e['roles'].include?('lgfs') }.uniq).to eq([true])
        end
      end

      it 'has all the expected keys' do
        %w{id name roles reason_set}.each do |key|
          expect(parsed_body.first).to have_key(key)
        end
      end

      it 'has correct roles' do
        expect(parsed_body.first['roles'].size).to eq(2)
        expect(parsed_body.first['roles']).to include('agfs')
        expect(parsed_body.first['roles']).to include('lgfs')
      end
    end

    context 'without api key' do
      let(:params) { {} }

      it 'should require an API key' do
        expect(last_response.status).to eq 401
        expect(last_response.body).to include('Unauthorised')
      end
    end
  end
end
