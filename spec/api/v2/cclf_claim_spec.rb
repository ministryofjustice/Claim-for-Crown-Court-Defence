require 'rails_helper'
require 'spec_helper'
require 'api_spec_helper'

RSpec::Matchers.define :be_valid_cclf_claim_json do
  match do |response|
    schema_path = ClaimJsonSchemaValidator::CCLF_SCHEMA_FILE
    @errors = JSON::Validator.fully_validate(schema_path, response.respond_to?(:body) ? response.body : response)
    @errors.empty?
  end

  description do
    "be valid against the CCLF claim JSON schema"
  end

  failure_message do |response|
    spacer = "\s" * 2
    "expected JSON to be valid against CCLF formatted claim schema but the following errors were raised:\n" +
    @errors.each_with_index.map { |error, idx| "#{spacer}#{idx+1}. #{error}"}.join("\n")
  end
end

RSpec.shared_examples 'returns LGFS claim type' do |type|
  subject { last_response.status }
  let(:case_type_grtrl) { create(:case_type, :grtrl) }

  it "returns #{type.to_s.humanize}s" do
    claim = create(type, :submitted)
    claim.update!(case_type: case_type_grtrl)
    do_request(claim_uuid: claim.uuid)
    is_expected.to eq 200
  end
end

describe API::V2::CCLFClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  def is_valid_cclf_json(response)
    expect(response).to be_valid_cclf_claim_json
  end

  after(:all) { clean_database }

  before(:all) do
    @case_worker = create(:case_worker, :admin)
    @claim = create(:litigator_claim, :without_fees, :submitted)
  end

  def do_request(claim_uuid: @claim.uuid, api_key: @case_worker.user.api_key)
    get "/api/cclf/claims/#{claim_uuid}", {api_key: api_key}, {format: :json}
  end

  describe 'GET /ccr/claim/:uuid?api_key=:api_key' do
    include_examples 'returns LGFS claim type', :litigator_claim
    include_examples 'returns LGFS claim type', :interim_claim
    include_examples 'returns LGFS claim type', :transfer_claim

    it 'returns 406, Not Acceptable, if requested API version (via header) is not supported' do
      header 'Accept-Version', 'v1'
      do_request
      expect(last_response.status).to eq 406
      expect(last_response.body).to include('The requested version is not supported.')
    end

    it 'requires an API key' do
      do_request(api_key: nil)
      expect(last_response.status).to eq 401
      expect(last_response.body).to include('Unauthorised')
    end

    context 'when accessed by an ExternalUser' do
      before { do_request(api_key: @claim.external_user.user.api_key )}

      it 'returns unauthorised' do
        expect(last_response.status).to eq 401
        expect(last_response.body).to include('Unauthorised')
      end
    end

    context 'claim not found' do
      it 'returns not found response when claim uuid does not exist' do
        do_request(claim_uuid: '123-456-789')
        expect(last_response.status).to eq 404
        expect(last_response.body).to include('Claim not found')
      end

      it 'returns not found response when claim is not an LGFS claim' do
        claim = create(:advocate_claim, :submitted)
        do_request(claim_uuid: claim.uuid)
        is_expected.to eq 404
        expect(last_response.body).to include('Claim not found')
      end
    end

    context 'JSON response' do
      subject(:response) { do_request }

      it { is_valid_cclf_json(response) }
    end

    context 'defendants' do
      subject(:response) do
        do_request(claim_uuid: @claim.uuid, api_key: @case_worker.user.api_key).body
      end

      before do
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
      subject(:response) { do_request(claim_uuid: claim.uuid, api_key: @case_worker.user.api_key).body }
      subject(:bills) { JSON.parse(response)['bills'] }

      let(:claim) do
        create(:litigator_claim, :submitted, :without_fees)
      end

      it 'returns empty array if no bills found' do
        expect(response).to have_json_size(0).at_path("bills")
        expect(bills).to be_an Array
        expect(bills).to be_empty
      end

      context 'final claims' do
        context 'litigator fee' do
          context 'when graduated fee exists' do
            let(:grtrl){ create(:graduated_fee_type, :grtrl) }
            let(:case_type_grtrl) { create(:case_type, :grtrl) }
            let(:claim) do
              create(:litigator_claim, :without_fees, :submitted).tap do |claim|
                claim.update!(case_type: case_type_grtrl)
                create(:graduated_fee, fee_type: grtrl, claim: claim)
              end
            end

            it { is_valid_cclf_json(response) }

            it 'returns array containing a litigator fee bill' do
              expect(response).to have_json_size(1).at_path("bills")
            end

            it 'returns a litigator fee bill' do
              expect(response).to be_json_eql('LIT_FEE'.to_json).at_path("bills/0/bill_type")
              expect(response).to be_json_eql('LIT_FEE'.to_json).at_path("bills/0/bill_subtype")
            end
          end

          context 'when fixed fee exists' do
            let(:fxcbr) { create(:fixed_fee_type, :fxcbr) }
            let(:case_type_fxcbr) { create(:case_type, :cbr) }
            let(:claim) do
              create(:litigator_claim, :without_fees, :submitted).tap do |claim|
                claim.update!(case_type: case_type_fxcbr)
                create(:fixed_fee, :lgfs, fee_type: fxcbr, claim: claim)
              end
            end

            it { is_valid_cclf_json(response) }

            it 'returns array containing the bill' do
              expect(response).to have_json_size(1).at_path("bills")
            end

            it 'returns a litigator fee bill' do
              expect(response).to be_json_eql('LIT_FEE'.to_json).at_path("bills/0/bill_type")
              expect(response).to be_json_eql('LIT_FEE'.to_json).at_path("bills/0/bill_subtype")
            end
          end

          context 'when miscellaneous fees exists' do
            let(:mispf) { create(:misc_fee_type, :lgfs, :mispf) }
            let(:claim) do
              create(:litigator_claim, :submitted, :without_fees).tap do |claim|
                create(:misc_fee, :lgfs, fee_type: mispf, claim: claim)
              end
            end

            before do
              allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'FXACV'
            end

            it { is_valid_cclf_json(response) }

            it 'returns array containing fee bill' do
              expect(response).to have_json_size(1).at_path("bills")
            end

            it 'returns array containing a special prep fee bill' do
              expect(response).to be_json_eql('FEE_SUPPLEMENT'.to_json).at_path("bills/0/bill_type")
              expect(response).to be_json_eql('SPECIAL_PREP'.to_json).at_path("bills/0/bill_subtype")
            end
          end
        end
      end
    end
  end
end
