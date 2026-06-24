require 'rails_helper'

RSpec::Matchers.define :be_valid_cclf_claim_json do
  match do |response|
    schema = ClaimJsonSchemaValidator.cclf_schema
    @errors = JSON::Validator.fully_validate(schema, response.respond_to?(:body) ? response.body : response)
    @errors.empty?
  end

  description do
    'be valid against the CCLF claim JSON schema'
  end

  failure_message do
    spacer = "\s" * 2
    "expected JSON to be valid against CCLF formatted claim schema but the following errors were raised:\n" +
      @errors.each_with_index.map { |error, idx| "#{spacer}#{idx + 1}. #{error}" }.join("\n")
  end
end

RSpec.shared_examples 'returns LGFS claim type' do |type|
  subject { last_response.status }

  let(:case_type_grtrl) { create(:case_type, :trial) }

  it "returns #{type.to_s.humanize}s" do
    claim = create_claim(type, :submitted, case_type: case_type_grtrl, defendants: create_list(:defendant, 1))
    do_request(claim_uuid: claim.uuid)
    is_expected.to eq 200
  end
end

RSpec.shared_examples 'CCLF disbursement' do |options|
  let(:bill_index) { options.fetch(:bill_index, 0) }
  let(:bill_subtype) { options.fetch(:bill_subtype, 'NO_SUBTYPE_SPECFIFED') }

  it 'returns a disbursement bill type' do
    expect(parsed.dig('bills', bill_index, 'bill_type')).to eq('DISBURSEMENT')
  end

  it 'returns a disbursement bill subtype' do
    expect(parsed.dig('bills', bill_index, 'bill_subtype')).to eq(bill_subtype)
  end

  it 'exposes a net and vat amount' do
    expect(parsed.dig('bills', bill_index, 'net_amount')).not_to be_nil
    expect(parsed.dig('bills', bill_index, 'vat_amount')).not_to be_nil
  end
end

RSpec.shared_examples 'bill scenarios are based on case type' do
  context 'bill scenarios are based on case type' do
    it 'for trials' do
      allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'GRRTR'
      expect(parsed.dig('case_type', 'bill_scenario')).to eq('ST1TS0TA')
    end

    it 'for retrials' do
      allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'GRTRL'
      expect(parsed.dig('case_type', 'bill_scenario')).to eq('ST1TS0T4')
    end
  end
end

RSpec.shared_examples 'litigator fee bill' do
  it 'returns array containing 1 bill' do
    expect(parsed['bills'].size).to eq(1)
  end

  it 'returns a litigator fee bill' do
    expect(parsed.dig('bills', 0, 'bill_type')).to eq('LIT_FEE')
    expect(parsed.dig('bills', 0, 'bill_subtype')).to eq('LIT_FEE')
  end
end

RSpec.describe API::V2::CCLFClaim, feature: :injection do
  include Rack::Test::Methods
  include ApiSpecHelper

  after(:all) { clean_database }

  def create_claim(*)
    # TODO: this should not require build + save + reload
    # understand what the factory is doing to solve this
    claim = build(*)
    claim.save!
    claim.reload
  end

  let(:case_worker) { create(:case_worker, :admin) }
  let(:case_type) { create(:case_type, :trial) }
  let(:claim) { create_claim(:litigator_claim, :without_fees, :submitted, case_type:) }

  def do_request(claim_uuid: claim.uuid, api_key: case_worker.user.api_key)
    get "/api/cclf/claims/#{claim_uuid}", { api_key: }, { format: :json }
  end

  describe 'GET /ccr/claim/:uuid?api_key=:api_key' do
    include_examples 'returns LGFS claim type', :litigator_claim
    include_examples 'returns LGFS claim type', :interim_claim
    include_examples 'returns LGFS claim type', :transfer_claim

    it_behaves_like 'injection response statuses' do
      let(:invalid_claim) { create(:advocate_claim, :submitted) }
    end

    it 'returns valid JSON' do
      do_request
      expect(last_response).to be_valid_cclf_claim_json
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
      it { is_expected.to expose :main_hearing_date }
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

      let(:parsed) { JSON.parse(subject) }

      context 'when claim does not apply VAT' do
        before { claim.update(apply_vat: false) }

        it { expect(parsed['apply_vat']).to be(false) }
      end

      context 'when claim does apply VAT' do
        before { claim.update(apply_vat: true) }

        it { expect(parsed['apply_vat']).to be(true) }
      end
    end

    context 'case_type' do
      subject(:response) { do_request.body }

      let(:parsed) { JSON.parse(subject) }

      before do
        allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'FXCON'
      end

      it 'returns a bill scenario based on case type' do
        expect(parsed.dig('case_type', 'bill_scenario')).to eq('ST1TS0T8')
      end
    end

    it_behaves_like 'injection data with defendants' do
      let(:claim) do
        create_claim(
          :litigator_claim,
          :without_fees,
          :submitted,
          case_type:,
          defendants:
        )
      end
    end

    context 'bills' do
      subject(:response) { do_request.body }

      let(:parsed) { JSON.parse(subject) }
      let(:bills) { JSON.parse(response)['bills'] }
      let(:claim) { create_claim(:litigator_claim, :submitted, :without_fees, case_type: case_type_grtrl) }
      let(:case_type_grtrl) { create(:case_type, :trial) }

      it 'returns empty array if no bills found' do
        expect(parsed['bills'].size).to eq(0)
        expect(bills).to be_an Array
        expect(bills).to be_empty
      end

      it 'returns no bill for bills without a bill type' do
        claim.update!(case_type: case_type_grtrl)
        fee_type = create(:misc_fee_type, unique_code: 'XXXXX')
        create(:misc_fee, claim:, fee_type:, amount: 51.01)
        expect(bills).to be_empty
      end

      context 'final claims' do
        context 'litigator fee' do
          context 'when graduated fee exists' do
            let(:grtrl) { create(:graduated_fee_type, :grtrl) }
            let(:graduated_fee) { create(:graduated_fee, fee_type: grtrl, quantity: 1000) }
            let(:claim) { create_claim(:litigator_claim, :without_fees, :submitted, case_type: case_type_grtrl, graduated_fee:) }

            it { expect(response).to be_valid_cclf_claim_json }

            it_behaves_like 'litigator fee bill'

            context 'with any type of grad fee' do
              before { allow_any_instance_of(Fee::GraduatedFeeType).to receive(:unique_code).and_return 'XXXXX' }

              it_behaves_like 'litigator fee bill'
            end

            it 'returns quantity of ppe' do
              expect(parsed.dig('bills', 0, 'quantity')).to eq('1000')
            end
          end

          context 'when fixed fee exists' do
            let(:fxcbr) { create(:fixed_fee_type, :fxcbr) }
            let(:case_type_fxcbr) { create(:case_type, :cbr) }
            let(:fixed_fee) { create(:fixed_fee, :lgfs, fee_type: fxcbr) }
            let(:claim) { create_claim(:litigator_claim, :without_fees, :submitted, case_type: case_type_fxcbr, fixed_fee:) }

            it { expect(response).to be_valid_cclf_claim_json }

            it_behaves_like 'litigator fee bill'
          end

          context 'when miscellaneous fees exists' do
            let(:claim) { create_claim(:litigator_claim, :submitted, :without_fees, case_type:, misc_fees: [misc_fee]) }
            let(:case_type) { build(:case_type, :trial) }
            let(:misc_fee) { build(:misc_fee, :lgfs, fee_type:) }

            before do
              allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'FXACV'
            end

            context 'with a mappable fee type - Special preparation' do
              let(:fee_type) { create(:misc_fee_type, :lgfs, :mispf) }

              it { expect(response).to be_valid_cclf_claim_json }

              it 'returns array containing fee bill' do
                expect(parsed['bills'].size).to eq(1)
              end

              it 'returns array containing a special prep fee bill' do
                expect(parsed.dig('bills', 0, 'bill_type')).to eq('FEE_SUPPLEMENT')
                expect(parsed.dig('bills', 0, 'bill_subtype')).to eq('SPECIAL_PREP')
              end
            end

            context 'with an unmappable fee type - Unused materials (over 3 hours)' do
              let(:fee_type) { create(:misc_fee_type, :miumo) }

              before { expect(claim.misc_fees.count).to eq 1 }

              it 'returns array containing no fee bill' do
                expect(parsed['bills'].size).to eq(0)
              end
            end
          end

          context 'when warrant fee exists' do
            let(:warr) { create(:warrant_fee_type, :warr) }
            let(:case_type_fxcbr) { create(:case_type, :cbr) }
            let(:warrant_fee) { create(:warrant_fee, fee_type: warr) }
            let(:claim) { create_claim(:litigator_claim, :without_fees, :submitted, case_type: case_type_fxcbr, warrant_fee:) }

            it { expect(response).to be_valid_cclf_claim_json }

            it 'returns array containing the bill' do
              expect(parsed['bills'].size).to eq(1)
            end

            it 'returns a warrant fee bill' do
              expect(parsed.dig('bills', 0, 'bill_type')).to eq('FEE_ADVANCE')
              expect(parsed.dig('bills', 0, 'bill_subtype')).to eq('WARRANT')
            end
          end

          context 'when disbursements exist' do
            let(:forensic) { create(:disbursement_type, :forensic) }
            let(:disbursement) { build(:disbursement, disbursement_type: forensic) }
            let(:claim) { create_claim(:litigator_claim, :submitted, :without_fees, disbursements: [disbursement]) }

            before do
              allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'FXACV'
            end

            it { expect(response).to be_valid_cclf_claim_json }

            it 'returns array containing fee bill' do
              expect(parsed['bills'].size).to eq(1)
            end

            it_behaves_like 'CCLF disbursement', bill_subtype: 'FORENSICS'
          end

          context 'when expenses exist' do
            let(:expense) { create(:expense, :bike_travel, amount: 9.99, vat_amount: 1.99) }
            let(:claim) { create_claim(:litigator_claim, :submitted, :without_fees, expenses: [expense]) }

            before do
              allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return 'FXCBR'
            end

            it { expect(response).to be_valid_cclf_claim_json }

            it 'returns array containing fee bill' do
              expect(parsed['bills'].size).to eq(1)
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

          it { expect(response).to be_valid_cclf_claim_json }

          it_behaves_like 'litigator fee bill'

          it 'returns a bill scenario based on the interim fee type' do
            expect(parsed.dig('case_type', 'bill_scenario')).to eq('ST1TS0T0')
          end
        end

        context 'when disbursements exist' do
          subject(:response) { do_request.body }

          let(:forensic) { create(:disbursement_type, :forensic) }
          let(:disbursement) { build(:disbursement, disbursement_type: forensic) }
          let(:claim) { create_claim(:interim_claim, :disbursement_only_fee, :submitted, case_type:, disbursements: [disbursement]) }

          it { expect(response).to be_valid_cclf_claim_json }

          it 'returns array containing fee bill' do
            expect(parsed['bills'].size).to eq(1)
          end

          it_behaves_like 'CCLF disbursement', bill_subtype: 'FORENSICS'
          include_examples 'bill scenarios are based on case type'
        end

        context 'when interim warrant fee exists' do
          let(:claim) { create(:interim_claim, :interim_warrant_fee, :submitted, case_type:) }

          it { expect(response).to be_valid_cclf_claim_json }

          it 'returns array containing the bill' do
            expect(parsed['bills'].size).to eq(1)
          end

          it 'returns a warrant fee bill' do
            expect(parsed.dig('bills', 0, 'bill_type')).to eq('FEE_ADVANCE')
            expect(parsed.dig('bills', 0, 'bill_subtype')).to eq('WARRANT')
          end

          include_examples 'bill scenarios are based on case type'

          context 'with expense' do
            before do
              create(:expense, :bike_travel, claim:, amount: 9.99, vat_amount: 1.99)
            end

            it { expect(response).to be_valid_cclf_claim_json }

            it 'returns array containing 2 bills' do
              expect(parsed['bills'].size).to eq(2)
            end

            it_behaves_like 'CCLF disbursement', bill_subtype: 'TRAVEL COSTS', bill_index: 1
          end
        end
      end

      context 'tranfer claims' do
        let(:claim) { create(:transfer_claim, :with_transfer_detail, :submitted) }

        context 'when transfer fee, alone, exists' do
          it { expect(response).to be_valid_cclf_claim_json }

          it_behaves_like 'litigator fee bill'

          it 'returns a bill scenario based on transfer details' do
            expect(parsed.dig('case_type', 'bill_scenario')).to eq('ST4TS0T3')
          end
        end

        context 'when disbursements exist' do
          subject(:response) { do_request.body }

          let(:forensic) { create(:disbursement_type, :forensic) }
          let(:claim) do
            create(:transfer_claim, :with_transfer_detail, :submitted).tap do |claim|
              claim.disbursements.delete_all
              create(:disbursement, disbursement_type: forensic, claim:)
            end
          end

          it { expect(response).to be_valid_cclf_claim_json }

          it 'returns array containing 2 bill' do
            expect(parsed['bills'].size).to eq(2)
          end

          it 'returns array containing a tranfer bill' do
            expect(parsed.dig('bills', 0, 'bill_subtype')).to eq('LIT_FEE')
          end

          it_behaves_like 'CCLF disbursement', bill_subtype: 'FORENSICS', bill_index: 1
        end

        context 'when expenses exist' do
          let(:claim) do
            create(:transfer_claim, :with_transfer_detail, :submitted).tap do |claim|
              create(:expense, :bike_travel, claim:, amount: 9.98, vat_amount: 1.98)
            end
          end

          it { expect(response).to be_valid_cclf_claim_json }

          it 'returns array containing 2 bills' do
            expect(parsed['bills'].size).to eq(2)
          end

          it_behaves_like 'CCLF disbursement', bill_subtype: 'TRAVEL COSTS', bill_index: 1
        end

        context 'when miscellaneous fees exists' do
          let(:mispf) { create(:misc_fee_type, :lgfs, :mispf) }
          let(:claim) do
            create(:transfer_claim, :with_transfer_detail, :submitted).tap do |claim|
              create(:misc_fee, :lgfs, fee_type: mispf, claim:)
            end
          end

          it { expect(response).to be_valid_cclf_claim_json }

          it 'returns array containing 2 bills' do
            expect(parsed['bills'].size).to eq(2)
          end

          it 'returns array containing a special prep fee bill' do
            expect(parsed.dig('bills', 1, 'bill_type')).to eq('FEE_SUPPLEMENT')
            expect(parsed.dig('bills', 1, 'bill_subtype')).to eq('SPECIAL_PREP')
          end
        end

        context 'when unmappable miscellaneous fees exists' do
          let(:miupl) { create(:misc_fee_type, :lgfs, :miupl) }
          let(:claim) do
            create(:transfer_claim, :with_transfer_detail, :submitted).tap do |claim|
              create(:misc_fee, :lgfs, fee_type: miupl, claim:)
            end
          end

          it { expect(response).to be_valid_cclf_claim_json }

          it 'returns array NOT containing misc fee bills' do
            expect(parsed['bills'].size).to eq(1)
            expect(parsed.dig('bills', 0, 'bill_type')).to eq('LIT_FEE')
          end
        end
      end

      context 'hardship claims' do
        context 'when hardship fee, alone, exists' do
          let(:claim) { create(:litigator_hardship_claim, :submitted, :with_hardship_fee) }

          it { expect(response).to be_valid_cclf_claim_json }

          it 'returns array containing 1 bill' do
            expect(parsed['bills'].size).to eq(1)
          end

          it 'returns a litigator fee bill' do
            expect(parsed.dig('bills', 0, 'bill_type')).to eq('FEE_ADVANCE')
            expect(parsed.dig('bills', 0, 'bill_subtype')).to eq('HARDSHIP')
          end

          it 'returns a bill scenario based on transfer details' do
            expect(parsed.dig('case_type', 'bill_scenario')).to eq('ST2TS1T0')
          end
        end

        context 'when an additional misc fee exists' do
          let(:claim) do
            create(:litigator_hardship_claim, :submitted, :with_hardship_fee).tap do |claim|
              create(:misc_fee, :lgfs, claim:, amount: '45', fee_type:)
            end
          end
          let(:fee_type) { build(:misc_fee_type, :lgfs, :mievi) }

          it { expect(response).to be_valid_cclf_claim_json }

          it 'returns array containing 2 bills' do
            expect(parsed['bills'].size).to eq(2)
          end

          it 'returns a litigator fee bill' do
            expect(parsed.dig('bills', 1, 'bill_type')).to eq('EVID_PROV_FEE')
            expect(parsed.dig('bills', 1, 'bill_subtype')).to eq('EVID_PROV_FEE')
          end

          it 'returns a bill scenario based on transfer details' do
            expect(parsed.dig('case_type', 'bill_scenario')).to eq('ST2TS1T0')
          end
        end
      end
    end
  end
end
