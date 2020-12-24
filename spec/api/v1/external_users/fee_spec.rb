require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Fee do
  include Rack::Test::Methods
  include ApiSpecHelper

  ALL_FEE_ENDPOINTS = [endpoint(:fees, :validate), endpoint(:fees)]
  FORBIDDEN_FEE_VERBS = [:get, :put, :patch, :delete]

  def create_claim(*args)
    # TODO: this should not require build + save + reload
    # understand what the factory is doing to solve this
    claim = build(*args)
    claim.save
    claim.reload
  end

  let!(:provider) { create(:provider) }
  let!(:other_provider) { create(:provider) }
  let!(:basic_fee_type) { create(:basic_fee_type) }
  let!(:basic_fee_dat_type) { create(:basic_fee_type, :dat) }
  let!(:misc_fee_type) { create(:misc_fee_type) }
  let!(:misc_fee_xupl_type) { create(:misc_fee_type, :miupl) }
  let!(:fixed_fee_type) { create(:fixed_fee_type) }
  let!(:interim_fee_type) { create(:interim_fee_type) }
  let!(:graduated_fee_type) { create(:graduated_fee_type) }
  let!(:transfer_fee_type) { create(:transfer_fee_type) }

  before { seed_fee_schemes }

  let!(:claim) { create(:claim, source: 'api').reload }
  let(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: misc_fee_type.id, quantity: 3, rate: 50.00 } }
  let(:json_error_response) { [{ 'error' => 'Type of fee not found by ID or Unique Code' }].to_json }

  context 'sending non-permitted verbs' do
    ALL_FEE_ENDPOINTS.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        FORBIDDEN_FEE_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it "#{api_verb.upcase} should return a status of 405" do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  describe "POST #{endpoint(:fees)}" do
    def post_to_create_endpoint
      post endpoint(:fees), valid_params, format: :json
    end

    include_examples 'should NOT be able to amend a non-draft claim'

    context 'when fee params are valid' do
      it 'should create fee, return 201 and fee JSON output including UUID' do
        post_to_create_endpoint
        expect(last_response.status).to eq 201
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect(Fee::BaseFee.find_by(uuid: json['id']).uuid).to eq(json['id'])
        expect(Fee::BaseFee.find_by(uuid: json['id']).claim.uuid).to eq(json['claim_id'])
      end

      it 'should create one new fee' do
        expect { post_to_create_endpoint }.to change { Fee::BaseFee.count }.by(1)
      end

      it 'should create a new fee record with all provided attributes except amount' do
        post_to_create_endpoint
        fee = Fee::BaseFee.last
        expect(fee.claim_id).to eq claim.id
        expect(fee.fee_type_id).to eq misc_fee_type.id
        expect(fee.quantity).to eq valid_params[:quantity]
        expect(fee.rate).to eq valid_params[:rate]
      end

      context 'fee_type_unique_code' do
        let(:unique_code) { misc_fee_type.unique_code }

        it 'should create a new fee record with a fee type specified by unique code' do
          valid_params.delete(:fee_type_id)
          valid_params.merge!(fee_type_unique_code: unique_code)

          post_to_create_endpoint
          expect(last_response.status).to eq 201

          fee = Fee::BaseFee.last
          expect(fee.claim_id).to eq claim.id
          expect(fee.fee_type_id).to eq misc_fee_type.id
          expect(fee.quantity).to eq valid_params[:quantity]
          expect(fee.rate).to eq valid_params[:rate]
          expect(fee.fee_type.unique_code).to eq(unique_code)
        end
      end

      context 'when fee amount provided' do
        context 'with quantity and rate' do
          let(:valid_params) do
            {
              api_key: provider.api_key,
              claim_id: claim.uuid,
              fee_type_id: misc_fee_type.id,
              quantity: 3,
              rate: 50.00,
              amount: 151.00
            }
          end

          it 'calculates amount based on quantity x rate (all except PPE/NPW)' do
            post_to_create_endpoint
            fee = Fee::BaseFee.last
            expect(fee).to have_attributes(quantity: 3, rate: 50.00, amount: 150.00)
          end
        end

        context 'without quantity and rate' do
          context 'fixed fees' do
            let(:claim) { create(:litigator_claim, :with_fixed_fee_case, :without_fees, source: 'api').reload }
            let(:valid_params) do
              {
                api_key: provider.api_key,
                claim_id: claim.uuid,
                fee_type_id: fee_type.id,
                date: '2018-04-19',
                quantity: nil,
                rate: nil,
                amount: 349.47
              }
            end

            context 'calculated fee with amount but no quantity and rate' do
              let(:fee_type) { create(:fixed_fee_type, calculated: true) }

              # Need comes out of shift from uncalculated to calculated LGFS fixed
              # fees to enable laa-fee-calculator API use.
              it 'populates quantity and rate to mimic amount supplied' do
                post_to_create_endpoint
                fee = Fee::BaseFee.last
                expect(fee).to have_attributes(quantity: 1, rate: 349.47, amount: 349.47)
              end
            end
          end
        end
      end

      context 'basic fees' do
        let!(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: basic_fee_type.id, quantity: 1, rate: 210.00 } }
        let(:json) { JSON.parse(last_response.body) }
        let(:fee) { Fee::BaseFee.find_by(uuid: json['id']) }

        it 'should return 200 and fee JSON output including UUID' do
          post_to_create_endpoint
          expect(last_response.status).to eq 200
          expect(json['id']).not_to be_nil
          expect(fee.uuid).to eq(json['id'])
          expect(fee.claim.uuid).to eq(json['claim_id'])
        end

        it 'should update, not create, one basic fee' do
          expect { post_to_create_endpoint }.to change { Fee::BaseFee.count }.by(0)
        end

        it 'should raise error if basic fee does not exist on claim' do
          valid_params.merge!(fee_type_id: basic_fee_dat_type.id)
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response('Basic fee not found on claim', 0)
        end

        it 'should update quantity, rate and amount' do
          post_to_create_endpoint
          expect(fee.claim_id).to eq claim.id
          expect(fee.fee_type_id).to eq basic_fee_type.id
          expect(fee.quantity).to eq 1
          expect(fee.rate).to eq 210.00
          expect(fee.amount).to eq 210.00
        end

        context 'agfs scheme 10' do
          let(:first_day_of_trial) { Settings.agfs_fee_reform_release_date }
          let(:actual_trial_length) { 5 }
          let(:trial_concluded_at) { first_day_of_trial + actual_trial_length.days }
          let(:case_type) { build(:case_type, :trial) }
          let(:basic_fees) {
            [
              build(:basic_fee, :baf_fee, quantity: 0, rate: 0.0, case_numbers: ''),
              build(:basic_fee, :dat_fee, quantity: 0, rate: 0.0, case_numbers: '')
            ]
          }
          let(:defendants) { [build(:defendant, representation_orders: [build(:representation_order, representation_order_date: first_day_of_trial)])] }
          let!(:claim) { create_claim(:advocate_claim, source: 'api', first_day_of_trial: first_day_of_trial, trial_concluded_at: trial_concluded_at, actual_trial_length: actual_trial_length, case_type: case_type, defendants: defendants, basic_fees: basic_fees) }
          let(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: basic_fee_dat_type.id, quantity: 2, rate: 600.00 } }

          it 'should return 200 and fee JSON output including UUID' do
            post_to_create_endpoint
            expect(last_response.status).to eq 200
            expect(json['id']).not_to be_nil
            expect(fee.uuid).to eq(json['id'])
            expect(fee.claim.uuid).to eq(json['claim_id'])
          end

          it 'should update quantity, rate and amount' do
            post_to_create_endpoint
            expect(fee.claim_id).to eq claim.id
            expect(fee.fee_type_id).to eq basic_fee_dat_type.id
            expect(fee.quantity).to eq 2
            expect(fee.rate).to eq 600.00
            expect(fee.amount).to eq 1200.00
          end
        end
      end

      context 'basic fees of type case uplift' do
        let!(:fee) { create(:basic_fee, :noc_fee, claim: claim, quantity: 0, rate: 0.0, case_numbers: '') }
        let!(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: fee.fee_type_id, quantity: 2, rate: 201.01, case_numbers: 'T20170001,T20170002' } }

        context 'when valid' do
          it 'updates the basic fee with the provided quantity, rate, case_numbers and calculated amount' do
            post_to_create_endpoint
            json = JSON.parse(last_response.body)
            fee = Fee::BasicFee.find_by(uuid: json['id'])
            expect(fee.claim_id).to eq claim.id
            expect(fee.quantity).to eq 2
            expect(fee.rate).to eq 201.01
            expect(fee.amount).to eq 402.02
            expect(fee.case_numbers).to eq 'T20170001,T20170002'
          end
        end
      end

      context 'fixed fees of type case uplift' do
        let!(:claim) { create(:advocate_claim, :with_fixed_fee_case, source: 'api') }
        let!(:fixed_fee_noc_type) { create(:fixed_fee_type, :fxnoc) }
        let!(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: fixed_fee_noc_type.id, quantity: 1, rate: 201.01, case_numbers: 'T20170001' } }

        context 'when valid' do
          it 'creates the fixed fee with the provided quantity, rate, case_numbers and calculated amount' do
            post_to_create_endpoint
            json = JSON.parse(last_response.body)
            fee = Fee::FixedFee.find_by(uuid: json['id'])
            expect(fee.claim_id).to eq claim.id
            expect(fee.quantity).to eq 1
            expect(fee.rate).to eq 201.01
            expect(fee.amount).to eq 201.01
            expect(fee.case_numbers).to eq 'T20170001'
          end
        end
      end

      context 'misc fees of type defendant uplift' do
        context 'LGFS fees' do
          let(:claim) { create(:litigator_claim, source: 'api') }
          let!(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: misc_fee_xupl_type.id, amount: 210 } }

          it 'creates the misc fee with the provided amount' do
            post_to_create_endpoint
            json = JSON.parse(last_response.body)
            fee = Fee::MiscFee.find_by(uuid: json['id'])
            expect(fee.claim_id).to eq claim.id
            expect(fee.fee_type_id).to eq misc_fee_xupl_type.id
            expect(fee.amount).to eq 210.00
          end
        end
      end
    end

    context 'fee type specific errors' do
      let!(:valid_params) do
        { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: misc_fee_type.id, quantity: 3, rate: 50.00 }
      end

      it 'basic (code BAF) fee should raise basic fee errors' do
        valid_params.delete(:rate)
        valid_params[:fee_type_id] = basic_fee_type.id
        basic_fee_type.update(code: 'BAF') # need to use real basic fee codes to trigger code specific validation and errors
        post_to_create_endpoint
        expect(last_response.status).to eq 400
        expect_error_response('Enter a quantity of 0 to 1 for basic fee',0)
        # NOTE: basic fee should allow 0 rate for claim basic fee at instantiation/creation but not thereafter
        expect_error_response('Enter a valid rate for the basic fee',1)
      end

      it 'uncalculated fees (PPE/NPW) should raise an error when rate provided' do
        valid_params[:fee_type_id] = basic_fee_type.id
        valid_params.merge!(rate: 25)
        basic_fee_type.update(code: 'PPE', calculated: false) # need to use real basic fee codes to trigger code specific validation and errors
        post_to_create_endpoint
        expect(last_response.status).to eq 400
        expect_error_response('Pages of prosecution evidence fees must not have a rate',0)
      end

      context 'quantity is forbidden' do
        context 'for interim fee disbursement only' do
          let!(:interim_fee_type) { create(:interim_fee_type, :disbursement_only) }
          let!(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: interim_fee_type.id, quantity: 3, rate: 50.00 } }

          it 'should raise error if quantity is provided' do
            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect_error_response('Do not enter a PPE quantity for the interim fee',0)
          end
        end

        context 'for interim fee warrant only' do
          let!(:interim_fee_type) { create(:interim_fee_type, :warrant) }
          let!(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: interim_fee_type.id, quantity: 3, rate: 50.00 } }

          it 'should raise error if quantity is provided' do
            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect_error_response('Do not enter a PPE quantity for the interim fee',0)
          end
        end
      end

      context 'quantity as decimal or integer' do
        let!(:special_preparation_fee) { create(:misc_fee_type, :spf) }
        let(:parsed_response) { JSON.parse(last_response.body) }

        it 'decimal quantity should raise error if fee type does NOT accept decimal quantities' do
          valid_params[:quantity] = 9.5
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response('You must specify a whole number for this type of fee',0)
        end

        it 'decimal quantity should NOT raise error if fee type accepts decimals quantities' do
          valid_params[:fee_type_id] = special_preparation_fee.id
          valid_params[:quantity] = 9.5
          post_to_create_endpoint
          expect(last_response.status).to eq 201
          fee = Fee::BaseFee.find_by(uuid: parsed_response['id'])
          expect(fee.quantity).to eq 9.5
        end
      end

      # NOT exhaustive
      context 'Fee Category' do
        before (:each) { valid_params.delete(:rate) }

        context 'advocate (final) claim' do
          it 'basic fees should raise basic fee errors from translations' do
            valid_params[:fee_type_id] = basic_fee_type.id
            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect_error_response('Enter a valid rate for the basic fee',0)
          end

          it 'misc fees should raise misc fee errors from translations' do
            valid_params[:fee_type_id] = misc_fee_type.id
            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect_error_response('Enter a rate/net amount for the miscellaneous fee',0)
          end

          it 'fixed fees should raise fixed fee errors from translations' do
            valid_params[:fee_type_id] = fixed_fee_type.id
            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect_error_response('Enter a rate/net amount for the fixed fee', 0)
          end
        end

        context 'litigator (interim) claim' do
          let!(:claim) { create(:interim_claim, source: 'api').reload }

          it 'interim fees should raise interim fee errors from translations' do
            valid_params[:fee_type_id] = interim_fee_type.id
            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect_error_response('Enter a valid amount for the interim fee',0)
          end
        end

        context 'litigator (final) claim' do
          let!(:claim) { create(:litigator_claim, source: 'api').reload }

          it 'graduated fees should raise graduated fee errors from translations' do
            valid_params[:fee_type_id] = graduated_fee_type.id
            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect_error_response('Enter the graduated fee date',0)
          end
        end

        context 'litigator (transfer) claim' do
          let!(:claim) { create(:transfer_claim, source: 'api').reload }

          it 'transfer fees should raise transfer fee errors from translations' do
            valid_params[:fee_type_id] = transfer_fee_type.id
            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect_error_response('Enter a valid amount for the transfer fee',0)
          end
        end
      end
    end

    context 'when fee params are invalid' do
      include_examples 'invalid API key create endpoint', exclude: :other_provider

      context 'missing expected params' do
        it 'should return a JSON error array with required model attributes' do
          valid_params.delete(:fee_type_id)
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          json = JSON.parse(last_response.body)
          expect(last_response.body).to eq json_error_response
        end
      end

      context 'mutually exclusive params fee_type_id and fee_type_unique_code' do
        it 'should return an error if both are provided' do
          valid_params[:fee_type_unique_code] = 'XXX'
          expect(valid_params.keys).to include(:fee_type_id, :fee_type_unique_code)

          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect(last_response.body).to include('fee_type_id, fee_type_unique_code are mutually exclusive')
        end
      end

      context 'unexpected error' do
        it 'should return 400 and JSON error array of error message' do
          allow(API::Helpers::ApiHelper).to receive(:validate_resource).and_raise(RangeError)
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          result_hash = JSON.parse(last_response.body)
          expect(result_hash).to eq([{ 'error' => 'RangeError' }])
        end
      end

      context 'missing claim id' do
        it 'should return 400 and a JSON error array' do
          valid_params.delete(:claim_id)
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response('Claim cannot be blank',0)
        end
      end

      context 'invalid claim id' do
        it 'should return 400 and a JSON error array' do
          valid_params[:claim_id] = SecureRandom.uuid
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect_error_response('Claim cannot be blank',0)
        end
      end

      context 'malformed claim UUID' do
        it 'should reject invalid claim id' do
          valid_params[:claim_id] = 'any-old-rubbish'
          post_to_create_endpoint
          expect(last_response.status).to eq(400)
          expect_error_response('Claim cannot be blank',0)
        end
      end
    end
  end

  describe "POST #{endpoint(:fees, :validate)}" do
    def post_to_validate_endpoint
      post endpoint(:fees, :validate), valid_params, format: :json
    end

    include_examples 'invalid API key validate endpoint', exclude: :other_provider

    context 'non-basic fees' do
      include_examples 'fee validate endpoint'
    end

    context 'basic fees' do
      let!(:valid_params) { { api_key: provider.api_key, claim_id: claim.uuid, fee_type_id: basic_fee_type.id, quantity: 1, rate: 210.00 } }
      include_examples 'fee validate endpoint'
    end
  end
end
