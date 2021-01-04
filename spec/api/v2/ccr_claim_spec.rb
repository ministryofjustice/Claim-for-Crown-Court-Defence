require 'rails_helper'

RSpec::Matchers.define :be_valid_ccr_claim_json do
  match do |response|
    schema_path = ClaimJsonSchemaValidator::CCR_SCHEMA_FILE
    @errors = JSON::Validator.fully_validate(schema_path, response.respond_to?(:body) ? response.body : response)
    @errors.empty?
  end

  description do
    'be valid against the CCR claim JSON schema'
  end

  failure_message do |response|
    spacer = "\s" * 2
    "expected JSON to be valid against CCR formatted claim schema but the following errors were raised:\n" +
    @errors.each_with_index.map { |error, idx| "#{spacer}#{idx + 1}. #{error}" }.join("\n")
  end
end

RSpec.describe API::V2::CCRClaim, feature: :injection do
  include Rack::Test::Methods
  include ApiSpecHelper

  after(:all) { clean_database }

  def create_claim(*args)
    # TODO: this should not require build + save + reload
    # understand what the factory is doing to solve this
    claim = build(*args)
    claim.save
    claim.reload
  end

  let(:case_worker) { create(:case_worker, :admin) }
  let(:case_type) { create(:case_type, :trial) }
  let(:basic_fee) { build(:basic_fee, :baf_fee, quantity: 1) }
  let(:misc_fee) { build(:misc_fee, :mispf_fee, :with_date_attended) }
  let(:claim) { create(:submitted_claim, :without_fees, case_type: case_type, basic_fees: [basic_fee], misc_fees: [misc_fee]) }

  def do_request(claim_uuid: claim.uuid, api_key: case_worker.user.api_key)
    get "/api/ccr/claims/#{claim_uuid}", { api_key: api_key }, { format: :json }
  end

  describe 'GET /ccr/claim/:uuid?api_key=:api_key' do
    let(:dsl) { Grape::DSL::InsideRoute }

    context 'response statuses' do
      it 'returns 200, success, and JSON response when existing claim exists and api key authorised' do
        do_request
        expect(last_response.status).to eq 200
        expect(last_response).to be_valid_ccr_claim_json
      end

      it 'returns 401 when API key not provided' do
        do_request(api_key: nil)
        expect(last_response.status).to eq 401
        expect(last_response.body).to include('Unauthorised')
      end

      it 'returns 401, Unauthorised when api key is for an external user' do
        do_request(api_key: claim.external_user.user.api_key)
        expect(last_response.status).to eq 401
        expect(last_response.body).to include('Unauthorised')
      end

      it 'returns 404, Claim not found when claim does not exist' do
        do_request(claim_uuid: '123-456-789')
        expect(last_response.status).to eq 404
        expect(last_response.body).to include('Claim not found')
      end

      it 'returns 406, Not Acceptable, if requested API version (via header) is not supported' do
        header 'Accept-Version', 'v1'
        do_request
        expect(last_response.status).to eq 406
        expect(last_response.body).to include('The requested version is not supported.')
      end
    end

    context 'entities' do
      context 'with advocate "final" claims' do
        it 'presents claim with CCR final claim entity' do
          expect_any_instance_of(dsl).to receive(:present).with(instance_of(Claim::AdvocateClaim), with: API::Entities::CCR::FinalClaim)
          do_request
        end
      end

      context 'with advocate interim claims' do
        let(:warrant_fee) { build(:warrant_fee, :warr_fee) }
        let(:offence) { create(:offence, :with_fee_scheme_ten) }
        let(:claim) { create_claim(:advocate_interim_claim, :without_fees, :submitted, offence: offence, warrant_fee: warrant_fee) }

        it 'presents claim with CCR interim claim entity' do
          expect_any_instance_of(dsl).to receive(:present).with(instance_of(Claim::AdvocateInterimClaim), with: API::Entities::CCR::InterimClaim)
          do_request
        end
      end

      context 'with advocate supplementary claims' do
        let(:claim) { create(:advocate_supplementary_claim, :submitted) }

        it 'presents claim with CCR supplementary claim entity' do
          expect_any_instance_of(dsl).to receive(:present).with(instance_of(Claim::AdvocateSupplementaryClaim), with: API::Entities::CCR::SupplementaryClaim)
          do_request
        end
      end

      context 'with advocate hardship claims' do
        let(:claim) { create(:advocate_hardship_claim, :submitted) }

        it 'presents claim with CCR hardship claim entity' do
          expect_any_instance_of(dsl).to receive(:present).with(instance_of(Claim::AdvocateHardshipClaim), with: API::Entities::CCR::HardshipClaim)
          do_request
        end
      end
    end

    context 'advocate "final" claims' do
      subject(:response) { do_request.body }

      it { is_expected.to expose :uuid }
      it { is_expected.to expose :supplier_number }
      it { is_expected.to expose :case_number }
      it { is_expected.to expose :first_day_of_trial }
      it { is_expected.to expose :trial_fixed_notice_at }
      it { is_expected.to expose :trial_fixed_at }
      it { is_expected.to expose :trial_cracked_at }
      it { is_expected.to expose :retrial_started_at }
      it { is_expected.to expose :trial_cracked_at_third }
      it { is_expected.to expose :last_submitted_at }

      it { is_expected.to expose :advocate_category }
      it { is_expected.to expose :case_type }
      it { is_expected.to expose :court }
      it { is_expected.to expose :offence }
      it { is_expected.to expose :defendants }
      it { is_expected.to expose :retrial_reduction }

      it { is_expected.to expose :actual_trial_Length }
      it { is_expected.to expose :estimated_trial_length }
      it { is_expected.to expose :retrial_actual_length }
      it { is_expected.to expose :retrial_estimated_length }

      it { is_expected.to expose :additional_information }
      it { is_expected.to expose :bills }
    end

    context 'advocate interim claim' do
      subject(:response) { do_request.body }

      let(:warrant_fee) { build(:warrant_fee, :warr_fee) }
      let(:offence) { create(:offence, :with_fee_scheme_ten) }
      let(:claim) { create_claim(:advocate_interim_claim, :without_fees, :submitted, offence: offence, warrant_fee: warrant_fee) }

      it { is_expected.to expose :uuid }
      it { is_expected.to expose :supplier_number }
      it { is_expected.to expose :case_number }
      it { is_expected.not_to expose :first_day_of_trial }
      it { is_expected.not_to expose :trial_fixed_notice_at }
      it { is_expected.not_to expose :trial_fixed_at }
      it { is_expected.not_to expose :trial_cracked_at }
      it { is_expected.not_to expose :retrial_started_at }
      it { is_expected.not_to expose :trial_cracked_at_third }
      it { is_expected.to expose :last_submitted_at }

      it { is_expected.to expose :advocate_category }
      it { is_expected.to expose :case_type }
      it { is_expected.to expose :court }
      it { is_expected.to expose :offence }
      it { is_expected.to expose :defendants }
      it { is_expected.not_to expose :retrial_reduction }

      it { is_expected.to expose :actual_trial_Length }
      it { is_expected.to expose :estimated_trial_length }
      it { is_expected.to expose :retrial_actual_length }
      it { is_expected.to expose :retrial_estimated_length }

      it { is_expected.to expose :additional_information }
      it { is_expected.to expose :bills }
    end

    context 'advocate supplementary claim' do
      subject(:response) { do_request.body }

      let(:claim) { create_claim(:advocate_supplementary_claim, :submitted) }

      it { is_expected.to expose :uuid }
      it { is_expected.to expose :supplier_number }
      it { is_expected.to expose :case_number }
      it { is_expected.not_to expose :first_day_of_trial }
      it { is_expected.not_to expose :trial_fixed_notice_at }
      it { is_expected.not_to expose :trial_fixed_at }
      it { is_expected.not_to expose :trial_cracked_at }
      it { is_expected.not_to expose :retrial_started_at }
      it { is_expected.not_to expose :trial_cracked_at_third }
      it { is_expected.to expose :last_submitted_at }

      it { is_expected.to expose :advocate_category }
      it { is_expected.to expose :case_type }
      it { is_expected.to expose :court }
      it { is_expected.not_to expose :offence }
      it { is_expected.to expose :defendants }
      it { is_expected.not_to expose :retrial_reduction }

      it { is_expected.to expose :actual_trial_Length }
      it { is_expected.to expose :estimated_trial_length }
      it { is_expected.to expose :retrial_actual_length }
      it { is_expected.to expose :retrial_estimated_length }

      it { is_expected.to expose :additional_information }
      it { is_expected.to expose :bills }
    end

    context 'advocate hardship claims' do
      subject(:response) { do_request.body }

      let(:claim) { create(:advocate_hardship_claim, case_stage: build(:case_stage, :trial_not_concluded)) }

      it { is_expected.to expose :uuid }
      it { is_expected.to expose :supplier_number }
      it { is_expected.to expose :case_number }
      it { is_expected.to expose :first_day_of_trial }
      it { is_expected.to expose :trial_fixed_notice_at }
      it { is_expected.to expose :trial_fixed_at }
      it { is_expected.to expose :trial_cracked_at }
      it { is_expected.to expose :retrial_started_at }
      it { is_expected.to expose :trial_cracked_at_third }
      it { is_expected.to expose :last_submitted_at }

      it { is_expected.to expose :advocate_category }
      it { is_expected.to expose :case_type }
      it { is_expected.to expose :court }
      it { is_expected.to expose :offence }
      it { is_expected.to expose :defendants }
      it { is_expected.to expose :retrial_reduction }

      it { is_expected.to expose :actual_trial_Length }
      it { is_expected.to expose :estimated_trial_length }
      it { is_expected.to expose :retrial_actual_length }
      it { is_expected.to expose :retrial_estimated_length }

      it { is_expected.to expose :additional_information }

      it { is_expected.to expose :bills }
      it { is_expected.to have_json_size(1).at_path('bills') }
    end

    context 'defendants' do
      subject(:response) { do_request.body }

      let(:defendants) { create_list(:defendant, 2) }
      let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, basic_fees: [basic_fee], misc_fees: [misc_fee], defendants: defendants) }

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

      let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type) }

      it 'returns empty array if no bills found' do
        is_expected.to have_json_size(0).at_path('bills')
        expect(bills).to be_an Array
        expect(bills).to be_empty
      end

      context 'advocate fee' do
        before do
          # TODO: Consider using seeds here maybe?
          create(:basic_fee_type, :babaf)
          create(:basic_fee_type, :basaf)
          create(:basic_fee_type, :bapcm)
          create(:basic_fee_type, :bappe)
          create(:basic_fee_type, :banoc)
          create(:basic_fee_type, :bandr)
          create(:basic_fee_type, :banpw)
          create(:basic_fee_type, :badaf)
          create(:basic_fee_type, :badah)
          create(:basic_fee_type, :badaj)
        end

        let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, basic_fees: [basic_fee]) }

        it { is_expected.to be_valid_ccr_claim_json }

        it 'not added to bills array when no basic fees are being claimed' do
          claim.reload # test failure without this on individual run???
          allow_any_instance_of(Fee::BasicFee).to receive_messages(rate: 0, quantity: 0, amount: 0)
          is_expected.to have_json_size(0).at_path('bills')
        end

        context 'when only inapplicable basic fees claimed' do
          let(:basic_fee) { build(:basic_fee, :pcm_fee, quantity: 2, amount: 2, rate: 1) }

          it 'not added to bills array' do
            expect(response).to_not include('"bill_type":"AGFS_FEE"')
          end
        end

        context 'bill type' do
          let(:basic_fee) { build(:basic_fee, :baf_fee, quantity: 1, rate: 25) }

          it 'property included' do
            is_expected.to have_json_path('bills/0/bill_type')
          end

          it 'property type valid' do
            is_expected.to have_json_type(String).at_path 'bills/0/bill_type'
          end

          it 'valid value included' do
            is_expected.to be_json_eql('AGFS_FEE'.to_json).at_path 'bills/0/bill_type'
          end
        end

        context 'bill sub type' do
          let(:basic_fee) { build(:basic_fee, :baf_fee, quantity: 1, rate: 25) }

          it 'property included' do
            is_expected.to have_json_path('bills/0/bill_subtype')
          end

          it 'property type valid' do
            is_expected.to have_json_type(String).at_path 'bills/0/bill_subtype'
          end

          it 'valid value included' do
            is_expected.to be_json_eql('AGFS_FEE'.to_json).at_path 'bills/0/bill_subtype'
          end
        end

        context 'pages of prosecution evidence' do
          let(:basic_fee) { build(:basic_fee, :ppe_fee, quantity: 1024, rate: 25) }

          it 'property included' do
            is_expected.to have_json_path('bills/0/ppe')
          end

          it 'property type valid' do
            is_expected.to have_json_type(String).at_path 'bills/0/ppe'
          end

          it 'value taken from the Pages of prosecution evidence Fee quantity' do
            is_expected.to be_json_eql('1024'.to_json).at_path 'bills/0/ppe'
          end
        end

        context 'number of cases uplifts' do
          let(:basic_fee) { build(:basic_fee, :noc_fee, quantity: 2, case_numbers: 'T20170001,T20170002') }

          it 'property included' do
            is_expected.to have_json_path('bills/0/number_of_cases')
          end

          it 'property type valid' do
            is_expected.to have_json_type(String).at_path 'bills/0/number_of_cases'
          end

          it 'calculated from Number of Cases uplift Fee quantity plus 1, for the "main" case' do
            is_expected.to be_json_eql('3'.to_json).at_path 'bills/0/number_of_cases'
          end
        end

        context 'case numbers' do
          let(:basic_fee) { build(:basic_fee, :noc_fee, quantity: 2, case_numbers: 'T20172765, T20172766') }

          it 'property included' do
            is_expected.to have_json_path('bills/0/case_numbers')
          end

          it 'property type valid' do
            is_expected.to have_json_type(String).at_path 'bills/0/case_numbers'
          end

          it 'value taken from the basic fee - number of case uplifts\' case_numbers attribute' do
            is_expected.to be_json_eql('T20172765, T20172766'.to_json).at_path 'bills/0/case_numbers'
          end
        end

        context 'number_of_defendants' do
          let(:basic_fees) { [build(:basic_fee, :baf_fee, quantity: 1)] }
          let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, basic_fees: basic_fees, misc_fees: [misc_fee]) }

          it 'property included' do
            is_expected.to have_json_path('bills/0/number_of_defendants')
          end

          it 'property type valid' do
            is_expected.to have_json_type(String).at_path 'bills/0/number_of_defendants'
          end

          it 'defaults to 1 if no defendant uplifts claimed' do
            is_expected.to be_json_eql('1'.to_json).at_path 'bills/0/number_of_defendants'
          end

          context 'when there is some defendant uplifts' do
            let(:basic_fees) {
              [
                build(:basic_fee, :baf_fee, quantity: 1),
                build(:basic_fee, :ndr_fee, quantity: 2)
              ]
            }

            it 'calculated from sum of Number of defendant uplift fee quantities plus one for main defendant' do
              expect(response).to be_json_eql('3'.to_json).at_path 'bills/0/number_of_defendants'
            end
          end
        end

        context 'number of prosecution witnesses' do
          let(:basic_fee) { build(:basic_fee, :npw_fee, quantity: 3) }

          it 'property included' do
            is_expected.to have_json_path('bills/0/number_of_witnesses')
          end

          it 'property type valid' do
            is_expected.to have_json_type(String).at_path 'bills/0/number_of_witnesses'
          end

          it 'property value determined from Number of Prosecution Witnesses Fee quantity' do
            is_expected.to be_json_eql('3'.to_json).at_path 'bills/0/number_of_witnesses'
          end
        end

        context 'daily attendances' do
          let(:basic_fees) { [build(:basic_fee, :baf_fee, quantity: 1)] }
          let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, basic_fees: basic_fees, misc_fees: [misc_fee]) }

          it 'includes property' do
            is_expected.to have_json_path('bills/0/daily_attendances')
            is_expected.to have_json_type(String).at_path 'bills/0/daily_attendances'
          end

          context 'upper bound value' do
            let(:basic_fees) {
              [
                build(:basic_fee, :baf_fee, quantity: 1),
                build(:basic_fee, :daf_fee, quantity: 38, rate: 1.0),
                build(:basic_fee, :dah_fee, quantity: 10, rate: 1.0),
                build(:basic_fee, :daj_fee, quantity: 1, rate: 1.0)
              ]
            }
            let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, basic_fees: basic_fees, misc_fees: [misc_fee], actual_trial_length: 53) }

            it 'calculated from Daily Attendanance Fee quantities if they exist' do
              is_expected.to be_json_eql('51'.to_json).at_path 'bills/0/daily_attendances'
            end
          end

          context 'lower bound value' do
            context 'for trials' do
              let(:case_type) { create(:case_type, :trial) }
              let(:actual_trial_length) { 1 }
              let(:trial_concluded_at) { 8.days.ago }
              let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, basic_fees: basic_fees, misc_fees: [misc_fee], first_day_of_trial: 10.days.ago, trial_concluded_at: trial_concluded_at, estimated_trial_length: 1, actual_trial_length: actual_trial_length) }

              context 'when no daily attendance fees and trial length is less than 2' do
                let(:actual_trial_length) { 1 }

                it 'calculated as actual trial length' do
                  expect(response).to be_json_eql('1'.to_json).at_path 'bills/0/daily_attendances'
                end
              end

              context 'when trial lengths over 2' do
                let(:actual_trial_length) { 4 }
                let(:trial_concluded_at) { 6.days.ago }

                it 'calculated as 2 for trial lengths over 2' do
                  expect(response).to be_json_eql('2'.to_json).at_path 'bills/0/daily_attendances'
                end
              end
            end

            context 'for retrials' do
              let(:case_type) { create(:case_type, :retrial) }
              let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, basic_fees: basic_fees, misc_fees: [misc_fee], first_day_of_trial: 10.days.ago, trial_concluded_at: 8.days.ago, estimated_trial_length: 2, actual_trial_length: 2, retrial_started_at: 5.days.ago, retrial_estimated_length: 1, retrial_actual_length: 1, retrial_concluded_at: 0.days.ago) }

              it 'calculated from actual retrial length if no daily attendance fees and retrial length is less than 2' do
                is_expected.to be_json_eql('1'.to_json).at_path 'bills/0/daily_attendances'
              end
            end
          end
        end
      end

      context 'fixed fees' do
        let(:case_type) { create(:case_type, :cbr) }
        let(:misc_fee) { build(:misc_fee, :mispf_fee, :with_date_attended) }
        let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, misc_fees: [misc_fee]) }

        before do
          # TODO: this should probably be using the seeds instead?!
          create(:fixed_fee_type, :fxcbr)
          create(:fixed_fee_type, :fxnoc)
          create(:fixed_fee_type, :fxacv)
          create(:fixed_fee_type, :fxndr)
        end

        context 'when applicable fixed fee claimed' do
          let(:fixed_fee) { build(:fixed_fee, :fxcbr_fee) }
          let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, fixed_fees: [fixed_fee]) }

          it { is_expected.to be_valid_ccr_claim_json }

          it 'added to bills' do
            is_expected.to have_json_size(1).at_path('bills')
          end
        end

        context 'when no applicable fixed fee claimed' do
          let(:fixed_fee) { build(:fixed_fee, :fxacv_fee, quantity: 13) }
          let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, fixed_fees: [fixed_fee]) }

          it 'fee does not impact the bill' do
            is_expected.to have_json_size(1).at_path('bills')
            is_expected.to_not be_json_eql('13'.to_json).at_path 'bills/0/daily_attendances'
          end
        end

        context 'when no fixed fee exists' do
          let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type) }

          it 'fixed fee matching the case type, with defaults, is added to bills' do
            is_expected.to have_json_size(1).at_path('bills')
            is_expected.to be_json_eql('AGFS_ORDER_BRCH'.to_json).at_path 'bills/0/bill_subtype'
            is_expected.to be_json_eql('1'.to_json).at_path 'bills/0/daily_attendances'
            is_expected.to be_json_eql('1'.to_json).at_path 'bills/0/number_of_cases'
            is_expected.to be_json_eql('1'.to_json).at_path 'bills/0/number_of_defendants'
          end
        end

        context 'daily attendances' do
          let(:fixed_fees) {
           [
             build(:fixed_fee, :fxcbr_fee, quantity: 3),
             build(:fixed_fee, :fxcbr_fee, quantity: 2)
           ]
          }
          let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, fixed_fees: fixed_fees) }

          it 'includes property' do
            is_expected.to have_json_path('bills/0/daily_attendances')
            is_expected.to have_json_type(String).at_path 'bills/0/daily_attendances'
          end

          it 'calculated from sum of all applicable fixed fee quantities' do
            is_expected.to be_json_eql('5'.to_json).at_path 'bills/0/daily_attendances'
          end
        end

        context 'case uplift details' do
          let(:fixed_fees) {
           [
             build(:fixed_fee, :fxcbr_fee, quantity: 1),
             build(:fixed_fee, :fxnoc_fee, quantity: 3, case_numbers: 'S20170003, S20170001, S20170002')
           ]
          }
          let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, fixed_fees: fixed_fees) }

          context 'number_of_cases' do
            it 'includes property' do
              is_expected.to have_json_path('bills/0/number_of_cases')
              is_expected.to have_json_type(String).at_path 'bills/0/number_of_cases'
            end

            it 'calculated from the count of UNIQUE additional case numbers for all uplift fees of the applicable variety (+1 for "main" case number) ' do
              is_expected.to be_json_eql('4'.to_json).at_path 'bills/0/number_of_cases'
            end
          end

          context 'case_numbers' do
            it 'includes property' do
              is_expected.to have_json_path('bills/0/case_numbers')
              is_expected.to have_json_type(String).at_path 'bills/0/case_numbers'
            end

            it 'consolidated list of UNIQUE additional case numbers for all uplift fees of the applicable variety' do
              %w{S20170001 S20170002 S20170003}.each do |case_number|
                is_expected.to include_json("#{case_number}".to_json).at_path 'bills/0/case_numbers'
              end
            end
          end
        end

        context 'number_of_defendants' do
          let(:fixed_fees) {
           [
             build(:fixed_fee, :fxcbr_fee, quantity: 1),
             build(:fixed_fee, :fxndr_fee, quantity: 1)
           ]
          }
          let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, fixed_fees: fixed_fees) }

          context 'without uplifts' do
            let(:fixed_fees) { [build(:fixed_fee, :fxcbr_fee, quantity: 1)] }

            it 'includes property' do
              expect(response).to have_json_path('bills/0/number_of_defendants')
              expect(response).to have_json_type(String).at_path 'bills/0/number_of_defendants'
            end
          end

          it 'calculated from sum of "number of defendants uplift" fee quanitities on claim plus one' do
            is_expected.to be_json_eql('2'.to_json).at_path 'bills/0/number_of_defendants'
          end
        end
      end

      context 'miscellaneous fees' do
        let(:misc_fees) { [build(:misc_fee, :miaph_fee)] }
        let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, misc_fees: misc_fees) }

        context 'when relevant CCCD fees exist' do
          it { is_expected.to be_valid_ccr_claim_json }

          it 'added to bills' do
            is_expected.to have_json_size(1).at_path('bills')
          end
        end

        context 'when no relevant cccd fee exists' do
          let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type) }

          it 'not added to bills if it is not a miscellaneous fee' do
            is_expected.to have_json_size(0).at_path('bills')
          end
        end

        context 'when CCCD fee exists but is excluded from injection' do
          context 'with "Conferences and views" - cannot be adapted' do
            let(:basic_fees) { [build(:basic_fee, :cav_fee, rate: 1, quantity: 8)] }
            let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, basic_fees: basic_fees) }

            before do
              # TODO: this should probably be using seeds instead
              create(:basic_fee_type, :cav)
            end

            it 'not added to bills if it is of an excluded fee type' do
              is_expected.to have_json_size(0).at_path('bills')
            end
          end

          context 'with Paper heavy case - does not exist in CCR' do
            let(:misc_fees) { [build(:misc_fee, :miphc_fee)] }
            let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, misc_fees: misc_fees) }

            it 'not added to bills if it is of an excluded fee type' do
              is_expected.to have_json_size(0).at_path('bills')
            end
          end
        end

        context 'when CCCD fee maps to a CCR misc fee' do
          let(:rate) { 0 }
          let(:quantity) { 0 }
          let(:basic_fees) { [build(:basic_fee, :pcm_fee, rate: rate, quantity: quantity)] }
          let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, basic_fees: basic_fees) }

          before do
            create(:basic_fee_type, :pcm)
          end

          context 'that has a value' do
            let(:quantity) { 2 }
            let(:rate) { 1 }

            it 'added to bills' do
              expect(response).to have_json_size(1).at_path('bills')
              expect(response).to be_json_eql('AGFS_MISC_FEES'.to_json).at_path 'bills/0/bill_type'
            end
          end

          it 'not added to bills if it has no value' do
            is_expected.to have_json_size(0).at_path('bills')
          end
        end

        context 'when CCCD fee has a defendant uplift' do
          context 'advocate final claim standard appearances' do
            let(:basic_fees) { [build(:basic_fee, :basaf_fee, rate: 91.0, quantity: 2)] }
            let(:misc_fees) { [build(:misc_fee, :misau_fee, rate: 18.20, quantity: 1)] }
            let(:claim) do
              create_claim(:submitted_claim, :without_fees, case_type: case_type).tap do |claim|
                claim.basic_fees << basic_fees
                claim.misc_fees << misc_fees
              end
            end

            it 'uplift not added to bill' do
              is_expected.to have_json_size(1).at_path('bills')
            end

            it 'uplift\'s parent fee type added to bill' do
              is_expected.to be_json_eql('AGFS_MISC_FEES'.to_json).at_path 'bills/0/bill_type'
              is_expected.to be_json_eql('AGFS_STD_APPRNC'.to_json).at_path 'bills/0/bill_subtype'
              is_expected.to be_json_eql('2.0'.to_json).at_path 'bills/0/quantity'
            end

            it 'uplift\'s quantity added to number of defendants on the parent' do
              is_expected.to be_json_eql('2'.to_json).at_path 'bills/0/number_of_defendants'
            end
          end

          context 'advocate supplementary claim standard appearances' do
            let(:misc_fees) { [build(:misc_fee, :misaf_fee, rate: 91.0, quantity: 2), build(:misc_fee, :misau_fee, rate: 18.20, quantity: 1)] }
            let(:claim) do
              create_claim(:advocate_supplementary_claim, :submitted, with_misc_fee: false).tap do |claim|
                claim.misc_fees << misc_fees
              end
            end

            it 'uplift not added to bill' do
              is_expected.to have_json_size(1).at_path('bills')
            end

            it 'uplift\'s parent fee type added to bill' do
              is_expected.to be_json_eql('AGFS_MISC_FEES'.to_json).at_path 'bills/0/bill_type'
              is_expected.to be_json_eql('AGFS_STD_APPRNC'.to_json).at_path 'bills/0/bill_subtype'
              is_expected.to be_json_eql('2.0'.to_json).at_path 'bills/0/quantity'
            end

            it 'uplift\'s quantity added to number of defendants on the parent' do
              is_expected.to be_json_eql('2'.to_json).at_path 'bills/0/number_of_defendants'
            end
          end
        end

        context 'bill type' do
          it 'property included' do
            is_expected.to have_json_path('bills/0/bill_type')
          end

          it 'property type valid' do
            is_expected.to have_json_type(String).at_path 'bills/0/bill_type'
          end

          it 'property value valid' do
            is_expected.to be_json_eql('AGFS_MISC_FEES'.to_json).at_path 'bills/0/bill_type'
          end
        end

        context 'bill sub type' do
          it 'property included' do
            is_expected.to have_json_path('bills/0/bill_subtype')
            is_expected.to have_json_type(String).at_path 'bills/0/bill_subtype'
          end

          it 'valid value included' do
            is_expected.to be_json_eql('AGFS_ABS_PRC_HF'.to_json).at_path 'bills/0/bill_subtype'
          end
        end
      end

      context 'warrant fees' do
        let(:warrant_fee) { build(:warrant_fee, :warr_fee) }
        let(:offence) { create(:offence, :with_fee_scheme_ten) }
        let(:case_type) { create(:case_type, :guilty_plea) }
        let(:claim) { create_claim(:advocate_interim_claim, :without_fees, case_type: case_type, warrant_fee: warrant_fee) }

        before do
          # TODO: we should probably be using the seeds instead
          create(:warrant_fee_type, :warr)
        end

        it { is_expected.to be_valid_ccr_claim_json }

        it 'returns array containing the bill' do
          is_expected.to have_json_size(1).at_path('bills')
        end

        it 'returns a warrant fee bill' do
          is_expected.to be_json_eql('AGFS_ADVANCE'.to_json).at_path('bills/0/bill_type')
          is_expected.to be_json_eql('AGFS_WARRANT'.to_json).at_path('bills/0/bill_subtype')
        end
      end

      context 'hardship fees' do
        before { seed_fee_schemes }

        let(:claim) { create(:advocate_hardship_claim, :agfs_scheme_9, case_stage: build(:case_stage, :trial_not_concluded)) }

        it { is_expected.to be_valid_ccr_claim_json }
        it { is_expected.to be_json_eql('AGFS_ADVANCE'.to_json).at_path 'bills/0/bill_type' }
        it { is_expected.to be_json_eql('AGFS_HARDSHIP'.to_json).at_path 'bills/0/bill_subtype' }
        it { is_expected.to have_json_path('bills/0/amount') }

        context 'with basic fees that map to misc fees exist' do
          before do
            claim.basic_fees.find_by(fee_type: Fee::BaseFeeType.find_by(unique_code: 'BABAF')).update(quantity: 1, rate: 10)
            claim.fees << build(:basic_fee, :daf_fee, quantity: 1, rate: 1, claim: claim) # add to hardship
            claim.fees << build(:basic_fee, :cav_fee, quantity: 1, rate: 100, claim: claim) # not added to hardship - a CCR misc fee that is NOT injected
            claim.fees << build(:basic_fee, :saf_fee, quantity: 1, rate: 100, claim: claim) # not added to hardship - a CCR misc fee that IS injected
            claim.fees << build(:basic_fee, :pcm_fee, quantity: 1, rate: 100, claim: claim) # not added to hardship - a CCR misc fee that IS injected
          end

          it 'adds CCR hardship fee to bills array' do
            expect(response).to include('"bill_type":"AGFS_ADVANCE"').and include('"bill_subtype":"AGFS_HARDSHIP"')
          end

          it 'does not add CCR advocate fee to bills array' do
            expect(response).to_not include('"bill_subtype":"AGFS_FEE"')
          end

          it 'converts CCCD BASAF to CCR misc fee AGFS_STD_APPRNC to bills array' do
            expect(response).to include('"bill_type":"AGFS_MISC_FEES"').and include('"bill_subtype":"AGFS_STD_APPRNC"')
          end

          it 'converts CCCD BAPCM to CCR misc fee AGFS_PLEA to bills array' do
            expect(response).to include('"bill_type":"AGFS_MISC_FEES"').and include('"bill_subtype":"AGFS_PLEA"')
          end

          it 'ignores CCCD BACAV fee' do
            expect(response).to_not include('"bill_subtype":"AGFS_CONFERENCE"')
          end
        end
      end

      context 'expenses' do
        context 'when an expense is claimed' do
          let(:expenses) { [build(:expense, :car_travel)] }
          let(:claim) { create_claim(:submitted_claim, :without_fees, case_type: case_type, expenses: expenses) }

          it { is_expected.to be_valid_ccr_claim_json }

          it 'added to bills' do
            is_expected.to have_json_size(1).at_path('bills')
          end
        end
      end
    end
  end
end
