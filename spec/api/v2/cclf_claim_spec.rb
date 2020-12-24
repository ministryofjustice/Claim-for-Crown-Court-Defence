require 'rails_helper'

RSpec::Matchers.define :be_valid_cclf_claim_json do
  match do |response|
    schema_path = ClaimJsonSchemaValidator::CCLF_SCHEMA_FILE
    @errors = JSON::Validator.fully_validate(schema_path, response.respond_to?(:body) ? response.body : response)
    @errors.empty?
  end

  description do
    'be valid against the CCLF claim JSON schema'
  end

  failure_message do |response|
    spacer = "\s" * 2
    "expected JSON to be valid against CCLF formatted claim schema but the following errors were raised:\n" +
    @errors.each_with_index.map { |error, idx| "#{spacer}#{idx + 1}. #{error}" }.join("\n")
  end
end

RSpec.shared_examples 'returns LGFS claim type' do |type|
  subject { last_response.status }
  let(:case_type_grtrl) { create(:case_type, :trial) }

  it "returns #{type.to_s.humanize}s" do
    claim = create_claim(type, :submitted, case_type: case_type_grtrl)
    do_request(claim_uuid: claim.uuid)
    is_expected.to eq 200
  end
end

RSpec.shared_examples 'CCLF disbursement' do |options|
  let(:bill_index) { options.fetch(:bill_index, 0) }
  let(:bill_subtype) { options.fetch(:bill_subtype, 'NO_SUBTYPE_SPECFIFED') }

  it 'returns a disbursement bill type' do
    expect(response).to be_json_eql('DISBURSEMENT'.to_json).at_path("bills/#{bill_index}/bill_type")
  end

  it 'returns a disbursement bill subtype' do
    expect(response).to be_json_eql(bill_subtype.to_json).at_path("bills/#{bill_index}/bill_subtype")
  end

  it 'exposes a net and vat amount' do
    expect(response).to have_json_path("bills/#{bill_index}/net_amount")
    expect(response).to have_json_path("bills/#{bill_index}/vat_amount")
  end
end

RSpec.shared_examples 'bill scenarios are based on case type' do
  context 'bill scenarios are based on case type' do
    it 'for trials' do
      allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'GRRTR'
      is_expected.to be_json_eql('ST1TS0TA'.to_json).at_path('case_type/bill_scenario')
    end

    it 'for retrials' do
      allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'GRTRL'
      is_expected.to be_json_eql('ST1TS0T4'.to_json).at_path('case_type/bill_scenario')
    end
  end
end

RSpec.shared_examples 'litigator fee bill' do
  it 'returns array containing 1 bill' do
    is_expected.to have_json_size(1).at_path('bills')
  end

  it 'returns a litigator fee bill' do
    is_expected.to be_json_eql('LIT_FEE'.to_json).at_path('bills/0/bill_type')
    is_expected.to be_json_eql('LIT_FEE'.to_json).at_path('bills/0/bill_subtype')
  end
end

RSpec.describe API::V2::CCLFClaim, feature: :injection do
  include Rack::Test::Methods
  include ApiSpecHelper

  def is_valid_cclf_json(response)
    expect(response).to be_valid_cclf_claim_json
  end

  def create_claim(*args)
    # TODO: this should not require build + save + reload
    # understand what the factory is doing to solve this
    claim = build(*args)
    claim.save
    claim.reload
  end

  after(:all) { clean_database }

  let(:case_worker) { create(:case_worker, :admin) }
  let(:case_type) { create(:case_type, :trial) }
  let(:claim) { create_claim(:litigator_claim, :without_fees, :submitted, case_type: case_type) }

  def do_request(claim_uuid: claim.uuid, api_key: case_worker.user.api_key)
    get "/api/cclf/claims/#{claim_uuid}", { api_key: api_key }, { format: :json }
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
      before { do_request(api_key: claim.external_user.user.api_key) }

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
        before { claim.update(apply_vat: false) }
        it { is_expected.to be_json_eql('false').at_path('apply_vat') }
      end

      context 'when claim does apply VAT' do
        before { claim.update(apply_vat: true) }
        it { is_expected.to be_json_eql('true').at_path('apply_vat') }
      end
    end

    context 'case_type' do
      subject(:response) { do_request.body }

      before do
        allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'FXCON'
      end

      it 'returns a bill scenario based on case type' do
        is_expected.to be_json_eql('ST1TS0T8'.to_json).at_path('case_type/bill_scenario')
      end
    end

    context 'defendants' do
      let(:defendants) { create_list(:defendant, 2) }
      let(:claim) { create_claim(:litigator_claim, :without_fees, :submitted, case_type: case_type, defendants: defendants) }

      subject(:response) { do_request.body }

      it 'returns multiple defendants' do
        is_expected.to have_json_size(2).at_path('defendants')
      end

      it 'returns defendants in order created marking earliest created as the "main" defendant' do
        is_expected.to be_json_eql('true').at_path('defendants/0/main_defendant')
      end

      context 'representation orders' do
        let(:defendants) {
          [
            create(:defendant, representation_orders: create_list(:representation_order, 2, representation_order_date: 5.days.ago)),
            create(:defendant, representation_orders: [create(:representation_order, representation_order_date: 2.days.ago)])
          ]
        }

        it 'returns the earliest of the representation orders' do
          is_expected.to have_json_size(1).at_path('defendants/0/representation_orders')
        end

        it 'returns earliest rep order first (per defendant)' do
          is_expected.to be_json_eql(claim.earliest_representation_order_date.to_json).at_path('defendants/0/representation_orders/0/representation_order_date')
        end
      end
    end

    context 'bills' do
      subject(:response) { do_request.body }

      let(:bills) { JSON.parse(response)['bills'] }
      let(:claim) { create_claim(:litigator_claim, :submitted, :without_fees, case_type: case_type_grtrl) }
      let(:case_type_grtrl) { create(:case_type, :trial) }

      it 'returns empty array if no bills found' do
        is_expected.to have_json_size(0).at_path('bills')
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
            let(:graduated_fee) { create(:graduated_fee, fee_type: grtrl, quantity: 1000) }
            let(:claim) { create_claim(:litigator_claim, :without_fees, :submitted, case_type: case_type_grtrl, graduated_fee: graduated_fee) }

            it { is_valid_cclf_json(response) }

            it_behaves_like 'litigator fee bill'

            context 'with any type of grad fee' do
              before { allow_any_instance_of(::Fee::GraduatedFeeType).to receive(:unique_code).and_return 'XXXXX' }
              it_behaves_like 'litigator fee bill'
            end

            it 'returns quantity of ppe' do
              is_expected.to be_json_eql('1000'.to_json).at_path('bills/0/quantity')
            end
          end

          context 'when fixed fee exists' do
            let(:fxcbr) { create(:fixed_fee_type, :fxcbr) }
            let(:case_type_fxcbr) { create(:case_type, :cbr) }
            let(:fixed_fee) { create(:fixed_fee, :lgfs, fee_type: fxcbr) }
            let(:claim) { create_claim(:litigator_claim, :without_fees, :submitted, case_type: case_type_fxcbr, fixed_fee: fixed_fee) }

            it { is_valid_cclf_json(response) }

            it_behaves_like 'litigator fee bill'
          end

          context 'when miscellaneous fees exists' do
            let(:claim) { create_claim(:litigator_claim, :submitted, :without_fees, misc_fees: [misc_fee]) }
            let(:misc_fee) { build(:misc_fee, :lgfs, fee_type: fee_type) }

            before do
              allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'FXACV'
            end

            context 'with a mappable fee type - Special preparation' do
              let(:fee_type) { create(:misc_fee_type, :lgfs, :mispf) }

              it { is_valid_cclf_json(response) }

              it 'returns array containing fee bill' do
                is_expected.to have_json_size(1).at_path('bills')
              end

              it 'returns array containing a special prep fee bill' do
                is_expected.to be_json_eql('FEE_SUPPLEMENT'.to_json).at_path('bills/0/bill_type')
                is_expected.to be_json_eql('SPECIAL_PREP'.to_json).at_path('bills/0/bill_subtype')
              end
            end

            context 'with an unmappable fee type - Unused materials (over 3 hours)' do
              let(:fee_type) { create(:misc_fee_type, :miumo) }

              before { expect(claim.misc_fees.count).to eql 1 }

              it 'returns array containing no fee bill' do
                is_expected.to have_json_size(0).at_path('bills')
              end
            end
          end

          context 'when warrant fee exists' do
            let(:warr) { create(:warrant_fee_type, :warr) }
            let(:case_type_fxcbr) { create(:case_type, :cbr) }
            let(:warrant_fee) { create(:warrant_fee, fee_type: warr) }
            let(:claim) { create_claim(:litigator_claim, :without_fees, :submitted, case_type: case_type_fxcbr, warrant_fee: warrant_fee) }

            it { is_valid_cclf_json(response) }

            it 'returns array containing the bill' do
              is_expected.to have_json_size(1).at_path('bills')
            end

            it 'returns a warrant fee bill' do
              is_expected.to be_json_eql('FEE_ADVANCE'.to_json).at_path('bills/0/bill_type')
              is_expected.to be_json_eql('WARRANT'.to_json).at_path('bills/0/bill_subtype')
            end
          end

          context 'when disbursements exist' do
            let(:forensic) { create(:disbursement_type, :forensic) }
            let(:disbursement) { build(:disbursement, disbursement_type: forensic) }
            let(:claim) { create_claim(:litigator_claim, :submitted, :without_fees, disbursements: [disbursement]) }

            before do
              allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'FXACV'
            end

            it { is_valid_cclf_json(response) }

            it 'returns array containing fee bill' do
              is_expected.to have_json_size(1).at_path('bills')
            end

            it_behaves_like 'CCLF disbursement', bill_subtype: 'FORENSICS'
          end

          context 'when expenses exist' do
            let(:expense) { create(:expense, :bike_travel, amount: 9.99, vat_amount: 1.99) }
            let(:claim) { create_claim(:litigator_claim, :submitted, :without_fees, expenses: [expense]) }

            before do
              allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'FXCBR'
            end

            it { is_valid_cclf_json(response) }

            it 'returns array containing fee bill' do
              is_expected.to have_json_size(1).at_path('bills')
            end

            it_behaves_like 'CCLF disbursement', bill_subtype: 'TRAVEL COSTS'
          end
        end
      end

      context 'interim claims' do
        let(:case_type_grrtr) { create(:case_type, :retrial) }

        context 'claim' do
          let(:claim) { create_claim(:interim_claim, :interim_trial_start_fee, :submitted) }

          it { is_expected.to expose :estimated_trial_length }
          it { is_expected.to expose :retrial_estimated_length }
        end

        context 'when interim fee exists, other than interim warrant or disbursement only' do
          let(:claim) { create(:interim_claim, :interim_effective_pcmh_fee, :submitted) }

          it { is_valid_cclf_json(response) }

          it_behaves_like 'litigator fee bill'

          it 'returns a bill scenario based on the interim fee type' do
            is_expected.to be_json_eql('ST1TS0T0'.to_json).at_path('case_type/bill_scenario')
          end
        end

        context 'when disbursements exist' do
          subject(:response) { do_request.body }

          let(:forensic) { create(:disbursement_type, :forensic) }
          let(:disbursement) { build(:disbursement, disbursement_type: forensic) }
          let(:claim) { create_claim(:interim_claim, :disbursement_only_fee, :submitted, case_type: case_type, disbursements: [disbursement]) }

          it { is_valid_cclf_json(response) }

          it 'returns array containing fee bill' do
            is_expected.to have_json_size(1).at_path('bills')
          end

          it_behaves_like 'CCLF disbursement', bill_subtype: 'FORENSICS'
          include_examples 'bill scenarios are based on case type'
        end

        context 'when interim warrant fee exists' do
          let(:claim) { create(:interim_claim, :interim_warrant_fee, :submitted, case_type: case_type) }

          it { is_valid_cclf_json(response) }

          it 'returns array containing the bill' do
            is_expected.to have_json_size(1).at_path('bills')
          end

          it 'returns a warrant fee bill' do
            is_expected.to be_json_eql('FEE_ADVANCE'.to_json).at_path('bills/0/bill_type')
            is_expected.to be_json_eql('WARRANT'.to_json).at_path('bills/0/bill_subtype')
          end

          include_examples 'bill scenarios are based on case type'

          context 'with expense' do
            before do
              create(:expense, :bike_travel, claim: claim, amount: 9.99, vat_amount: 1.99)
            end

            it { is_valid_cclf_json(response) }

            it 'returns array containing 2 bills' do
              is_expected.to have_json_size(2).at_path('bills')
            end

            it_behaves_like 'CCLF disbursement', bill_subtype: 'TRAVEL COSTS', bill_index: 1
          end
        end
      end

      context 'tranfer claims' do
        let(:claim) { create(:transfer_claim, :with_transfer_detail, :submitted) }

        context 'when transfer fee, alone, exists' do
          it { is_valid_cclf_json(response) }

          it_behaves_like 'litigator fee bill'

          it 'returns a bill scenario based on transfer details' do
            is_expected.to be_json_eql('ST4TS0T3'.to_json).at_path('case_type/bill_scenario')
          end
        end

        context 'when disbursements exist' do
          subject(:response) { do_request.body }

          let(:forensic) { create(:disbursement_type, :forensic) }
          let(:claim) do
            create(:transfer_claim, :with_transfer_detail, :submitted).tap do |claim|
              claim.disbursements.delete_all
              create(:disbursement, disbursement_type: forensic, claim: claim)
            end
          end

          it { is_valid_cclf_json(response) }

          it 'returns array containing 2 bill' do
            is_expected.to have_json_size(2).at_path('bills')
          end

          it 'returns array containing a tranfer bill' do
            is_expected.to be_json_eql('LIT_FEE'.to_json).at_path('bills/0/bill_subtype')
          end

          it_behaves_like 'CCLF disbursement', bill_subtype: 'FORENSICS', bill_index: 1
        end

        context 'when expenses exist' do
          let(:claim) do
            create(:transfer_claim, :with_transfer_detail, :submitted).tap do |claim|
              create(:expense, :bike_travel, claim: claim, amount: 9.98, vat_amount: 1.98)
            end
          end

          it { is_valid_cclf_json(response) }

          it 'returns array containing 2 bills' do
            is_expected.to have_json_size(2).at_path('bills')
          end

          it_behaves_like 'CCLF disbursement', bill_subtype: 'TRAVEL COSTS', bill_index: 1
        end

        context 'when miscellaneous fees exists' do
          let(:mispf) { create(:misc_fee_type, :lgfs, :mispf) }
          let(:claim) do
            create(:transfer_claim, :with_transfer_detail, :submitted).tap do |claim|
              create(:misc_fee, :lgfs, fee_type: mispf, claim: claim)
            end
          end

          it { is_valid_cclf_json(response) }

          it 'returns array containing 2 bills' do
            is_expected.to have_json_size(2).at_path('bills')
          end

          it 'returns array containing a special prep fee bill' do
            is_expected.to be_json_eql('FEE_SUPPLEMENT'.to_json).at_path('bills/1/bill_type')
            is_expected.to be_json_eql('SPECIAL_PREP'.to_json).at_path('bills/1/bill_subtype')
          end
        end

        context 'when unmappable miscellaneous fees exists' do
          let(:miupl) { create(:misc_fee_type, :lgfs, :miupl) }
          let(:claim) do
            create(:transfer_claim, :with_transfer_detail, :submitted).tap do |claim|
              create(:misc_fee, :lgfs, fee_type: miupl, claim: claim)
            end
          end

          it { is_valid_cclf_json(response) }

          it 'returns array NOT containing misc fee bills' do
            is_expected.to have_json_size(1).at_path('bills')
            is_expected.to be_json_eql('LIT_FEE'.to_json).at_path('bills/0/bill_type')
          end
        end
      end

      context 'hardship claims' do
        context 'when hardship fee, alone, exists' do
          let(:claim) { create(:litigator_hardship_claim, :submitted, :with_hardship_fee) }
          it { is_valid_cclf_json(response) }

          it 'returns array containing 1 bill' do
            is_expected.to have_json_size(1).at_path('bills')
          end

          it 'returns a litigator fee bill' do
            is_expected.to be_json_eql('FEE_ADVANCE'.to_json).at_path('bills/0/bill_type')
            is_expected.to be_json_eql('HARDSHIP'.to_json).at_path('bills/0/bill_subtype')
          end

          it 'returns a bill scenario based on transfer details' do
            is_expected.to be_json_eql('ST2TS1T0'.to_json).at_path('case_type/bill_scenario')
          end
        end

        context 'when an additional misc fee exists' do
          let(:claim) do
            create(:litigator_hardship_claim, :submitted, :with_hardship_fee).tap do |claim|
              create(:misc_fee, :lgfs, claim: claim, amount: '45', fee_type: fee_type)
            end
          end
          let(:fee_type) { build(:misc_fee_type, :lgfs, :mievi) }

          it { is_valid_cclf_json(response) }

          it 'returns array containing 2 bills' do
            is_expected.to have_json_size(2).at_path('bills')
          end

          it 'returns a litigator fee bill' do
            is_expected.to be_json_eql('EVID_PROV_FEE'.to_json).at_path('bills/1/bill_type')
            is_expected.to be_json_eql('EVID_PROV_FEE'.to_json).at_path('bills/1/bill_subtype')
          end

          it 'returns a bill scenario based on transfer details' do
            is_expected.to be_json_eql('ST2TS1T0'.to_json).at_path('case_type/bill_scenario')
          end
        end
      end
    end
  end
end
