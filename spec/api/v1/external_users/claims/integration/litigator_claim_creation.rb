require 'rails_helper'
require 'api_spec_helper'
require 'support/claim_api_endpoints'

RSpec::Matchers.define :be_valid_api_claim do |expected|
  match do |claim|
    @results = results(claim)
    @results.values.map{ |arr| arr.uniq.length.eql?(1) }.all?
  end

  def results_hash
    { valid: [], fee_scheme: [], offence: [], source: [], state: [], defendant_count: [], representation_orders_count: [], vat_amount: [], total: [] }
  end

  def results(claim)
    results = results_hash

    results[:valid][0] = expected.fetch(:valid, true)
    results[:valid][1] = claim.valid?
    results[:fee_scheme][0] = expected[:fee_scheme]
    results[:fee_scheme][1] = [claim.fee_scheme.name, claim.fee_scheme.version]
    results[:offence][0] = expected[:offence]
    results[:offence][1] = claim.offence
    results[:source][0] = expected.fetch(:source, 'api')
    results[:source][1] = claim.source
    results[:state][0] = expected.fetch(:state, 'draft')
    results[:state][1] = claim.state
    results[:defendant_count][0] = expected.fetch(:defendant_count, 1)
    results[:defendant_count][1] = claim.defendants.size
    results[:representation_orders_count][0] = expected.fetch(:representation_orders_count, 1)
    results[:representation_orders_count][1] = claim.defendants.first.representation_orders.size

    claim.reload
    results[:vat_amount][0] = expected[:vat_amount]
    results[:vat_amount][1] = claim.vat_amount.to_f
    results[:total][0] = expected[:total]
    results[:total][1] = claim.total.to_f
    results
  end

  description do
    "a valid api created claim with matching attributes"
  end

  failure_message do |owner|
    msg = "should be a valid API claim with matching attributes"
    failures = @results.select{ |_k, v| !v.uniq.length.eql?(1) }
    failures.each_pair do |k, v|
      msg += "\nexpected: #{k} to eql #{v[0].inspect.humanize} but got #{v[1].inspect.humanize}"
    end
    msg
  end
end

RSpec.describe 'API claim creation for LGFS' do
  include Rack::Test::Methods
  include ApiSpecHelper

  before do
    seed_fee_schemes
    seed_case_types
    seed_fee_types
    seed_expense_types
    seed_disbursement_types
  end

  let!(:provider) { create(:provider, :lgfs) }
  let!(:other_provider) { create(:provider) }
  let!(:vendor) { create(:external_user, :admin, provider: provider) }
  let!(:litigator) { create(:external_user, :litigator, provider: provider) }
  let!(:court) { create(:court)}

  let(:fixed_fee_type) { Fee::BaseFeeType.find_by(unique_code: 'FXACV') }
  let(:miscellaneous_fee_type) { Fee::BaseFeeType.find_by(unique_code: 'MIEVI') }
  let(:expense_car) { ExpenseType.find_by(unique_code: 'CAR') }
  let(:expense_hotel) { ExpenseType.find_by(unique_code: 'HOTEL') }
  let(:disbursement_type) { DisbursementType.find_by(unique_code: 'ARP')} # Accident reconstruction report

  let(:claim_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: litigator.user.email,
      supplier_number: provider.lgfs_supplier_numbers.first.supplier_number,
      case_type_id: case_type&.id,
      case_number: 'A20181234',
      providers_ref: 'A20181234/1',
      cms_number: 'Meridian',
      case_concluded_at: "2018-04-19",
      offence_id: nil,
      court_id: court.id,
      additional_information: 'Bish bosh bash'
    }
  end

  let(:defendant_params) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      first_name: "JohnAPI",
      last_name: "SmithAPI",
      date_of_birth: "1980-05-10"
    }
  end

  let(:representation_order_params) do
    {
        api_key: provider.api_key,
        defendant_id: nil,
        representation_order_date: representation_order_date,
        maat_reference: '2320006'
    }
  end

  let(:fixed_fee_params) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      fee_type_id: nil,
      date: "2018-04-19",
      quantity: 1,
      rate: 349.47
    }
  end

  let(:fixed_fee_params_with_amount) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      fee_type_id: nil,
      date: "2018-04-19",
      amount: 349.47
    }
  end

  let(:misc_fee_params) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      fee_type_id: nil,
      amount: 45.00,
    }
  end

  let(:expense_params) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      expense_type_id: nil,
      amount: 500,
      vat_amount: 100,
      location: 'London',
      distance: nil,
      reason_id: 5,
      reason_text: "Foo",
      mileage_rate_id: nil,
      date: "2018-04-19T12:30:00"
    }
  end

  def disbursement_params
    {
      api_key: provider.api_key,
      claim_id: nil,
      disbursement_type_id: nil,
      net_amount: 100.25,
      vat_amount: 20.05
    }
  end

  around do |example|
    result = example.run
    if result.is_a?(RSpec::Expectations::ExpectationNotMetError)
      begin
        puts JSON.parse(last_response.body).map{ |hash| hash['error'] }.join("\n").red
      rescue StandardError
        nil
      end
    end
  end

  # TODO: should be scheme 8 really, but has no impact
  context 'scheme 9' do
    context 'fixed fee claim' do
      let(:case_type) { CaseType.find_by(fee_type_code: 'FXACV') } # Appeal against conviction
      let(:representation_order_date) { Date.new(2018, 03, 31).as_json }

      specify "Case management system creates a valid scheme 9 fixed fee claim" do
        post ClaimApiEndpoints.for(:final).create, claim_params, format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: last_response_uuid )

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), fixed_fee_params.merge(claim_id: claim.uuid, fee_type_id: fixed_fee_type.id), format: :json
        expect(last_response.status).to eql 201

        fee = Fee::BaseFee.find_by(uuid: last_response_uuid )

        post endpoint(:fees), misc_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_fee_type.id), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:disbursements), disbursement_params.merge(claim_id: claim.uuid, disbursement_type_id: disbursement_type.id), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
        expect(last_response.status).to eql 201

        expect(claim).to be_valid_api_claim(fee_scheme: ['LGFS', 9], offence: nil, total: 1494.72, vat_amount: 220.05)
        expect(claim.fixed_fees.size).to eql 1
        expect(claim.expenses.size).to eql 2
        expect(claim.disbursements.size).to eql 1
      end
    end

    # changes to interface following LGFS fixed fee calculation render this
    # the old way of creating fixed fees but we still need to handle
    # API submissions (it takes 3 months+ for vendors to change their apps).
    context 'fixed fee claim with amount' do
      let(:case_type) { CaseType.find_by(fee_type_code: 'FXACV') } # Appeal against conviction
      let(:representation_order_date) { Date.new(2018, 03, 31).as_json }

      specify "Case management system creates a valid scheme 9 fixed fee claim" do
        post ClaimApiEndpoints.for(:final).create, claim_params, format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: last_response_uuid )

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), fixed_fee_params_with_amount.merge(claim_id: claim.uuid, fee_type_id: fixed_fee_type.id), format: :json
        expect(last_response.status).to eql 201

        fee = Fee::BaseFee.find_by(uuid: last_response_uuid )

        post endpoint(:fees), misc_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_fee_type.id), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:disbursements), disbursement_params.merge(claim_id: claim.uuid, disbursement_type_id: disbursement_type.id), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
        expect(last_response.status).to eql 201

        expect(claim).to be_valid_api_claim(fee_scheme: ['LGFS', 9], offence: nil, total: 1494.72, vat_amount: 220.05)
        expect(claim.fixed_fees.size).to eql 1
        expect(claim.expenses.size).to eql 2
        expect(claim.disbursements.size).to eql 1
      end
    end
  end
end
