require 'rails_helper'
require 'spec_helper'
require 'api_spec_helper'

RSpec::Matchers.define :be_valid_ccr_claim_json do
  match do |response|
    schema_path = ClaimJsonSchemaValidator::CCR_SCHEMA_FILE
    @errors = JSON::Validator.fully_validate(schema_path, response.body)
    @errors.empty?
  end

  description do
    "JSON is valid against the CCR claim JSON schema"
  end

  failure_message do |response|
    spacer = "\s" * 2
    "expected JSON to be valid against CCR formatted claim schema but the following errors were raised:\n" +
    @errors.each_with_index.map { |error, idx| "#{spacer}#{idx+1}. #{error}"}.join("\n")
  end
end

describe API::V2::CCRClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  after(:all) { clean_database }

  before(:all) do
    @case_worker = create(:case_worker, :admin)
    @claim = create(:authorised_claim)
  end

  # mock a Trial case type's fee_type_code as factories
  # do NOT create real/mappable fee type codes
  before do
    allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'GRTRL'
  end

  def do_request(claim_uuid: @claim.uuid, api_key: @case_worker.user.api_key)
    get "/api/ccr/claims/#{claim_uuid}", {api_key: api_key}, {format: :json}
  end

  describe 'GET /ccr/claim/:uuid?api_key=:api_key' do
    it 'should return 406 Not Acceptable if requested API version via header is not supported' do
      header 'Accept-Version', 'v1'

      do_request
      expect(last_response.status).to eq 406
      expect(last_response.body).to include('The requested version is not supported.')
    end

    it 'should require an API key' do
      do_request(api_key: nil)
      expect(last_response.status).to eq 401
      expect(last_response.body).to include('Unauthorised')
    end

    context 'claim not found' do
      it 'should respond not found when claim is not found' do
        do_request(claim_uuid: '123-456-789')
        expect(last_response.status).to eq 404
        expect(last_response.body).to include('Claim not found')
      end
    end

    context 'should return CCR compatible JSON' do
      subject(:response) { do_request }

      before do
        allow_any_instance_of(CaseType).to receive(:bill_scenario).and_return 'AS000004'
      end

      it 'should be valid against CCR claim JSON schema' do
        expect(response).to be_valid_ccr_claim_json
      end
    end

    context 'defendants' do
      subject(:response) do
        do_request(claim_uuid: @claim.uuid, api_key: @case_worker.user.api_key).body
      end

      before do
        @claim = create(:authorised_claim)

        travel_to 2.day.from_now do
          create(:defendant, claim: @claim)
        end
      end

      it 'returns multiple defendants' do
        expect(response).to have_json_size(2).at_path('defendants')
      end

      it 'returns defendants in order created marking earliest created as the "main" defendant' do
        expect(response).to be_json_eql('true').at_path('defendants/0/main_defendant')
      end

      context 'representation orders' do
        it 'returns multiple representation orders' do
          expect(response).to have_json_size(2).at_path('defendants/0/representation_orders')
        end

        # NOTE: use of factory defaults results in two rep orders for the first
        # defendant with dates 400 and 380 days before claim created
        it 'returns earliest rep order first (per defendant)' do
          expect(response).to be_json_eql(@claim.earliest_representation_order_date.to_json).at_path('defendants/0/representation_orders/0/representation_order_date')
        end
      end
    end

    context 'bills' do

      context 'bill type' do
        subject(:response) do
          do_request(claim_uuid: claim.uuid, api_key: @case_worker.user.api_key).body
        end

        let(:claim) { create(:authorised_claim) }

        it 'includes bill type' do
          expect(response).to have_json_path("bills/0/bill_type")
          expect(response).to have_json_type(String).at_path "bills/0/bill_type"
        end

        it 'returns advocate fee CCR bill type' do
          expect(response).to be_json_eql("AGFS_FEE".to_json).at_path "bills/0/bill_type"
        end
      end

      context 'bill sub type' do
        subject(:response) do
          do_request(claim_uuid: claim.uuid, api_key: @case_worker.user.api_key).body
        end

        let(:claim) { create(:authorised_claim) }

        it 'includes bill subtype' do
          expect(response).to have_json_path("bills/0/bill_subtype")
          expect(response).to have_json_type(String).at_path "bills/0/bill_subtype"
        end

        it 'returns CCR bill sub type' do
          expect(response).to be_json_eql("AGFS_FEE".to_json).at_path "bills/0/bill_subtype"
        end

        context 'mapping' do
          before do
            allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'FXACV'
          end

          it 'maps bill sub type based on the claims case type' do
            expect(response).to be_json_eql("AGFS_APPEAL_CON".to_json).at_path "bills/0/bill_subtype"
          end
        end
      end

      context 'pages of prosecution evidence' do
        subject(:response) do
          do_request(claim_uuid: claim.uuid, api_key: @case_worker.user.api_key).body
        end

        let(:claim) { create(:authorised_claim) }

        before do
          create(:basic_fee, :ppe_fee, claim: claim, quantity: 1024)
        end

        it 'includes ppe' do
          expect(response).to have_json_path("bills/0/ppe")
          expect(response).to have_json_type(Integer).at_path "bills/0/ppe"
        end

        it 'determines the Total number of pages of prosecution evidence from the Pages of proesecution evidence Fee quantity' do
          expect(response).to be_json_eql("1024").at_path "bills/0/ppe"
        end
      end

      context 'number of cases' do
        subject(:response) do
          do_request(claim_uuid: claim.uuid, api_key: @case_worker.user.api_key).body
        end

        let(:claim) { create(:authorised_claim) }

        before do
          create(:basic_fee, :noc_fee, claim: claim, quantity: 2)
        end

        it 'includes number of cases' do
          expect(response).to have_json_path("bills/0/number_of_cases")
          expect(response).to have_json_type(Integer).at_path "bills/0/number_of_cases"
        end

        it 'calculates Total number of cases from Number of Cases uplift Fee quantity plus 1, for the "main" case' do
          expect(response).to be_json_eql("3").at_path "bills/0/number_of_cases"
        end
      end

      context 'number of proseution witnesses' do
        subject(:response) do
          do_request(claim_uuid: claim.uuid, api_key: @case_worker.user.api_key).body
        end

        let(:claim) { create(:authorised_claim) }

        before do
          create(:basic_fee, :npw_fee, claim: claim, quantity: 3)
        end

        it 'includes number of witnesses' do
          expect(response).to have_json_path("bills/0/number_of_witnesses")
          expect(response).to have_json_type(Integer).at_path "bills/0/number_of_witnesses"
        end

        it 'determines number of witnesses from Number of Proseution Witnesses Fee quantity' do
          expect(response).to be_json_eql("3").at_path "bills/0/number_of_witnesses"
        end
      end

      context 'daily attendances' do
        subject(:response) do
          do_request(claim_uuid: claim.uuid, api_key: @case_worker.user.api_key).body
        end

        let(:claim) { create(:authorised_claim) }

        it 'includes daily attendances' do
          expect(response).to have_json_path("bills/0/daily_attendances")
          expect(response).to have_json_type(Integer).at_path "bills/0/daily_attendances"
        end

        context 'upper bounds' do
          before do
            claim.actual_trial_length = 51
            create(:basic_fee, :daf_fee, claim: claim, quantity: 38, rate: 1.0)
            create(:basic_fee, :dah_fee, claim: claim, quantity: 10, rate: 1.0)
            create(:basic_fee, :daj_fee, claim: claim, quantity: 1, rate: 1.0)
          end

          it 'calculates Total daily attendances from Daily Attendanance Fee quantities if they exist' do
            expect(response).to be_json_eql("51").at_path "bills/0/daily_attendances"
          end
        end

        context 'lower bounds' do
          it 'calculates Total daily attendances from acutal trial length if no daily attendance fees' do
            expect(response).to be_json_eql("0").at_path "bills/0/daily_attendances"
          end
        end
      end
    end
  end
end
