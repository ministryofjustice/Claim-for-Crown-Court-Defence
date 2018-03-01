require 'rails_helper'
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

RSpec.shared_examples 'CCLF disbursement' do |type|
  it 'returns a disbursement bill type' do
    expect(response).to be_json_eql('DISBURSEMENT'.to_json).at_path("bills/0/bill_type")
  end

  it 'exposes a net and vat amount' do
    expect(response).to have_json_path("bills/0/net_amount")
    expect(response).to have_json_path("bills/0/vat_amount")
  end
end

RSpec.shared_examples 'bill scenarios are based on case type' do
  context 'bill scenarios are based on case type' do
    it 'for trials' do
      allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'GRRTR'
      is_expected.to be_json_eql('ST1TS0TA'.to_json).at_path("case_type/bill_scenario")
    end

    it 'for retrials' do
      allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'GRTRL'
      is_expected.to be_json_eql('ST1TS0T4'.to_json).at_path("case_type/bill_scenario")
    end
  end
end

RSpec.describe API::V2::CCLFClaim, feature: :injection do
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

  before do
    allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'GRTRL'
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

    context 'claim' do
      subject(:response) { do_request.body }

      it { is_expected.to expose :uuid }
      it { is_expected.to expose :supplier_number }
      it { is_expected.to expose :case_number }
      it { is_expected.to expose :first_day_of_trial }
      it { is_expected.to expose :retrial_started_at }
      it { is_expected.to expose :case_concluded_at }
      it { is_expected.to expose :last_submitted_at }
      it { is_expected.to expose :actual_trial_Length }
      it { is_expected.to expose :case_type }
      it { is_expected.to expose :offence }
      it { is_expected.to expose :court }
      it { is_expected.to expose :defendants }
      it { is_expected.to expose :additional_information }
      it { is_expected.to expose :apply_vat }
      it { is_expected.to expose :bills }
    end

    context 'apply_vat' do
      subject(:response) { do_request.body }

      context 'when claim does not apply VAT' do
        before { @claim.update(apply_vat: false) }
        it { is_expected.to be_json_eql('false').at_path('apply_vat') }
      end

      context 'when claim does apply VAT' do
        before { @claim.update(apply_vat: true) }
        it { is_expected.to be_json_eql('true').at_path('apply_vat') }
      end
    end

    context 'case_type' do
      subject(:response) { do_request.body }

      before do
        allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'FXCON'
      end

      it 'returns a bill scenario based on case type' do
        is_expected.to be_json_eql('ST1TS0T8'.to_json).at_path("case_type/bill_scenario")
      end
    end

    context 'defendants' do
      subject(:response) { do_request(claim_uuid: @claim.uuid, api_key: @case_worker.user.api_key).body }

      before do
        travel_to 2.day.from_now do
          create(:defendant, claim: @claim)
        end
      end

      it 'returns multiple defendants' do
        is_expected.to have_json_size(2).at_path('defendants')
      end

      it 'returns defendants in order created marking earliest created as the "main" defendant' do
        is_expected.to be_json_eql('true').at_path('defendants/0/main_defendant')
      end

      context 'representation orders' do
        it 'returns multiple representation orders' do
          is_expected.to have_json_size(2).at_path('defendants/0/representation_orders')
        end

        # NOTE: use of factory defaults results in two rep orders for the first
        # defendant with dates 400 and 380 days before claim created
        it 'returns earliest rep order first (per defendant)' do
          is_expected.to be_json_eql(@claim.earliest_representation_order_date.to_json).at_path('defendants/0/representation_orders/0/representation_order_date')
        end
      end
    end

    context 'bills' do
      subject(:response) { do_request(claim_uuid: claim.uuid, api_key: @case_worker.user.api_key).body }
      let(:bills) { JSON.parse(response)['bills'] }

      let(:claim) do
        create(:litigator_claim, :submitted, :without_fees)
      end

      let(:case_type_grtrl) { create(:case_type, :grtrl) }

      it 'returns empty array if no bills found' do
        is_expected.to have_json_size(0).at_path("bills")
        expect(bills).to be_an Array
        expect(bills).to be_empty
      end

      it 'returns no bill for bills without a bill type' do
        claim.update!(case_type: case_type_grtrl)
        fee_type = create(:misc_fee_type, unique_code: 'XXXXX')
        create(:misc_fee, claim: claim, fee_type: fee_type, amount: 51.01)
        expect(bills).to be_empty
      end

      context 'final claims' do
        context 'litigator fee' do
          context 'when graduated fee exists' do
            let(:grtrl) { create(:graduated_fee_type, :grtrl) }
            let(:claim) do
              create(:litigator_claim, :without_fees, :submitted).tap do |claim|
                claim.update!(case_type: case_type_grtrl)
                create(:graduated_fee, fee_type: grtrl, claim: claim, quantity: 1000)
              end
            end

            it { is_valid_cclf_json(response) }

            it 'returns array containing a litigator fee bill' do
              is_expected.to have_json_size(1).at_path("bills")
            end

            it 'returns a litigator fee bill' do
              is_expected.to be_json_eql('LIT_FEE'.to_json).at_path("bills/0/bill_type")
              is_expected.to be_json_eql('LIT_FEE'.to_json).at_path("bills/0/bill_subtype")
            end

            it 'returns a litigator fee bill for any graduated fee' do
              allow_any_instance_of(::Fee::GraduatedFeeType).to receive(:unique_code).and_return 'XXXXX'
              is_expected.to be_json_eql('LIT_FEE'.to_json).at_path("bills/0/bill_type")
              is_expected.to be_json_eql('LIT_FEE'.to_json).at_path("bills/0/bill_subtype")
            end

            it 'returns quantity of ppe' do
              is_expected.to be_json_eql('1000'.to_json).at_path("bills/0/quantity")
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
              is_expected.to have_json_size(1).at_path("bills")
            end

            it 'returns a litigator fee bill' do
              is_expected.to be_json_eql('LIT_FEE'.to_json).at_path("bills/0/bill_type")
              is_expected.to be_json_eql('LIT_FEE'.to_json).at_path("bills/0/bill_subtype")
            end

            it 'returns 0 for quantity of ppe' do
              is_expected.to be_json_eql('0'.to_json).at_path("bills/0/quantity")
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
              is_expected.to have_json_size(1).at_path("bills")
            end

            it 'returns array containing a special prep fee bill' do
              is_expected.to be_json_eql('FEE_SUPPLEMENT'.to_json).at_path("bills/0/bill_type")
              is_expected.to be_json_eql('SPECIAL_PREP'.to_json).at_path("bills/0/bill_subtype")
            end
          end

          context 'when warrant fee exists' do
            let(:warr) { create(:warrant_fee_type, :warr) }
            let(:case_type_fxcbr) { create(:case_type, :cbr) }
            let(:claim) do
              create(:litigator_claim, :without_fees, :submitted).tap do |claim|
                claim.update!(case_type: case_type_fxcbr)
                create(:warrant_fee, fee_type: warr, claim: claim)
              end
            end

            it { is_valid_cclf_json(response) }

            it 'returns array containing the bill' do
              is_expected.to have_json_size(1).at_path("bills")
            end

            it 'returns a warrant fee bill' do
              is_expected.to be_json_eql('FEE_ADVANCE'.to_json).at_path("bills/0/bill_type")
              is_expected.to be_json_eql('WARRANT'.to_json).at_path("bills/0/bill_subtype")
            end
          end

          context 'when disbursements exist' do
            let(:forensic) { create(:disbursement_type, :forensic) }
            let(:claim) do
              create(:litigator_claim, :submitted, :without_fees).tap do |claim|
                create(:disbursement, disbursement_type: forensic, claim: claim)
              end
            end

            before do
              allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'FXACV'
            end

            it { is_valid_cclf_json(response) }

            it 'returns array containing fee bill' do
              is_expected.to have_json_size(1).at_path("bills")
            end

            it 'returns array containing a disbursement bill subtype' do
              is_expected.to be_json_eql('FORENSICS'.to_json).at_path("bills/0/bill_subtype")
            end

            it_behaves_like 'CCLF disbursement'
          end

          context 'when expenses exist' do
            let(:claim) do
              create(:litigator_claim, :submitted, :without_fees).tap do |claim|
                create(:expense, :bike_travel, claim: claim, amount: 9.99, vat_amount: 1.99)
              end
            end

            before do
              allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'FXCBR'
            end

            it { is_valid_cclf_json(response) }

            it 'returns array containing fee bill' do
              is_expected.to have_json_size(1).at_path("bills")
            end

            it 'returns array containing a travel costs disbursement bill sub type' do
              is_expected.to be_json_eql('TRAVEL COSTS'.to_json).at_path("bills/0/bill_subtype")
            end

            it_behaves_like 'CCLF disbursement'
          end
        end
      end

      context 'interim claims' do
        let(:case_type_grrtr) { create(:case_type, :retrial) }

        context 'claim' do
          let(:claim) { create(:interim_claim, :interim_trial_start_fee, :submitted) }

          it { is_expected.to expose :estimated_trial_length }
          it { is_expected.to expose :retrial_estimated_length }
        end

        context 'when interim fee exists, other than interim warrant or disbursement only' do
          let(:claim) { create(:interim_claim, :interim_effective_pcmh_fee, :submitted) }

          it { is_valid_cclf_json(response) }

          it 'returns array containing a litigator fee bill' do
            is_expected.to have_json_size(1).at_path("bills")
          end

          it 'returns a litigator fee bill' do
            is_expected.to be_json_eql('LIT_FEE'.to_json).at_path("bills/0/bill_type")
            is_expected.to be_json_eql('LIT_FEE'.to_json).at_path("bills/0/bill_subtype")
          end

          it 'returns a bill scenario based on the interim fee type' do
            is_expected.to be_json_eql('ST1TS0T0'.to_json).at_path("case_type/bill_scenario")
          end
        end

        context 'when disbursements exist' do
          subject(:response) { do_request(claim_uuid: claim.uuid, api_key: @case_worker.user.api_key).body }

          let(:forensic) { create(:disbursement_type, :forensic) }
          let(:claim) do
            create(:interim_claim, :disbursement_only_fee, :submitted).tap do |claim|
              claim.disbursements.delete_all
              create(:disbursement, disbursement_type: forensic, claim: claim)
            end
          end

          it { is_valid_cclf_json(response) }

          it 'returns array containing fee bill' do
            is_expected.to have_json_size(1).at_path("bills")
          end

          it 'returns array containing a disbursement bill subtype' do
            is_expected.to be_json_eql('FORENSICS'.to_json).at_path("bills/0/bill_subtype")
          end

          it_behaves_like 'CCLF disbursement'

          include_examples 'bill scenarios are based on case type'
        end

        context 'when interim warrant fee exists' do
          let(:claim) { create(:interim_claim, :interim_warrant_fee, :submitted) }

          it { is_valid_cclf_json(response) }

          it 'returns array containing the bill' do
            is_expected.to have_json_size(1).at_path("bills")
          end

          it 'returns a warrant fee bill' do
            is_expected.to be_json_eql('FEE_ADVANCE'.to_json).at_path("bills/0/bill_type")
            is_expected.to be_json_eql('WARRANT'.to_json).at_path("bills/0/bill_subtype")
          end

          include_examples 'bill scenarios are based on case type'

          context 'with expense' do
            before do
              create(:expense, :bike_travel, claim: claim, amount: 9.99, vat_amount: 1.99)
            end

            it { is_valid_cclf_json(response) }

            it 'returns array containing fee bill' do
              is_expected.to have_json_size(2).at_path("bills")
            end

            # TODO - replace with..
            # it_behaves_like 'CCLF disbursement', bill_subtype: 'TRAVEL COSTS', bill_index: 1
            # ... once transfer claims PR merged
            it 'returns array containing a travel costs disbursement bill sub type' do
              is_expected.to be_json_eql('DISBURSEMENT'.to_json).at_path("bills/1/bill_type")
              is_expected.to be_json_eql('TRAVEL COSTS'.to_json).at_path("bills/1/bill_subtype")
              is_expected.to have_json_path("bills/1/net_amount")
              is_expected.to have_json_path("bills/1/vat_amount")
            end
          end
        end
      end
    end
  end
end
