require 'rails_helper'

RSpec::Matchers.define :be_valid_api_lgfs_claim do |expected|
  match do |claim|
    @results = results(claim)
    @results.values.map { |arr| arr.uniq.length.eql?(1) }.all?
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
    'a valid api created claim with matching attributes'
  end

  failure_message do |owner|
    msg = 'should be a valid API claim with matching attributes'
    failures = @results.select { |_k, v| !v.uniq.length.eql?(1) }
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

  let!(:provider) { create(:provider, :lgfs, vat_registered: true) }
  let!(:other_provider) { create(:provider) }
  let!(:vendor) { create(:external_user, :admin, provider: provider) }
  let!(:litigator) { create(:external_user, :litigator, provider: provider) }
  let!(:court) { create(:court) }
  let(:offence_class) { create(:offence_class, class_letter: 'A') }
  let(:offence) { create(:offence, :with_fee_scheme, lgfs_fee_scheme: true, offence_class: offence_class) }

  let(:graduated_fee_type) { Fee::BaseFeeType.find_by(unique_code: 'GRTRL') }
  let(:fixed_fee_type) { Fee::BaseFeeType.find_by(unique_code: 'FXACV') }
  let(:interim_fee_type) { Fee::BaseFeeType.find_by(unique_code: 'INWAR') }
  let(:transfer_fee_type) { Fee::BaseFeeType.find_by(unique_code: 'TRANS') }
  let(:miscellaneous_fee_type) { Fee::BaseFeeType.find_by(unique_code: 'MIEVI') }
  let(:expense_car) { ExpenseType.find_by(unique_code: 'CAR') }
  let(:expense_hotel) { ExpenseType.find_by(unique_code: 'HOTEL') }
  let(:disbursement_type) { DisbursementType.find_by(unique_code: 'ARP') } # Accident reconstruction report

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
      case_concluded_at: '2018-04-19',
      offence_id: nil,
      actual_trial_length: nil,
      court_id: court.id,
      travel_expense_additional_information: 'Rail works required private car',
      additional_information: 'Bish bosh bash'
    }
  end

  let(:defendant_params) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      first_name: 'JohnAPI',
      last_name: 'SmithAPI',
      date_of_birth: '1980-05-10'
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

  let(:graduated_fee_params) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      fee_type_id: nil,
      date: '2018-04-19',
      quantity: 330,
      amount: 5142.87
    }
  end

  let(:interim_fee_params) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      fee_type_id: nil,
      warrant_issued_date: '2018-04-19',
      quantity: nil,
      amount: 200
    }
  end

  let(:transfer_detail_params) do
    {
      litigator_type: 'new',
      elected_case: false,
      transfer_stage_id: 10, # Up to and including PCMH transfer
      transfer_date: 1.month.ago.as_json,
      case_conclusion_id: 50 # Guilty plea
    }
  end

  let(:transfer_fee_params) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      fee_type_id: transfer_fee_type.id,
      quantity: nil, # PPE optional
      amount: 200
    }
  end

  let(:fixed_fee_params) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      fee_type_id: nil,
      date: '2018-04-19',
      quantity: 1,
      rate: 349.47
    }
  end

  let(:fixed_fee_params_with_amount) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      fee_type_id: nil,
      date: '2018-04-19',
      amount: 349.47
    }
  end

  let(:misc_fee_params) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      fee_type_id: nil,
      amount: 45.00
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
      reason_text: 'Foo',
      mileage_rate_id: nil,
      date: '2018-04-19T12:30:00'
    }
  end

  let(:disbursement_params) do
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
        puts JSON.parse(last_response.body).map { |hash| hash['error'] }.join("\n").red
      rescue StandardError
        nil
      end
    end
  end

  # TODO: should be LGFS scheme 8 really, but has no impact
  context 'scheme 9' do
    context 'graduated fee claim' do
      let(:case_type) { CaseType.find_by(fee_type_code: 'GRTRL') } # Trial
      let(:representation_order_date) { Date.new(2018, 03, 31).as_json }

      specify 'Case management system creates a valid scheme 9 graduated fee claim' do
        post ClaimApiEndpoints.for(:final).create, claim_params.merge(offence_id: offence.id, actual_trial_length: 10), format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: last_response_uuid)

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), graduated_fee_params.merge(claim_id: claim.uuid, fee_type_id: graduated_fee_type.id), format: :json
        expect(last_response.status).to eql 201

        expect(claim.graduated_fee).to be_present
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: offence, total: 5142.87, vat_amount: 1028.57)

        post endpoint(:fees), misc_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_fee_type.id), format: :json
        expect(last_response.status).to eql 201

        expect(claim.misc_fees.size).to eql 1
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: offence, total: 5187.87, vat_amount: 1037.57)

        post endpoint(:disbursements), disbursement_params.merge(claim_id: claim.uuid, disbursement_type_id: disbursement_type.id), format: :json
        expect(last_response.status).to eql 201

        expect(claim.disbursements.size).to eql 1
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: offence, total: 5288.12, vat_amount: 1057.62)

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
        expect(last_response.status).to eql 201

        expect(claim.expenses.size).to eql 2
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: offence, total: 6288.12, vat_amount: 1257.62)
      end
    end

    context 'fixed fee claim' do
      let(:case_type) { CaseType.find_by(fee_type_code: 'FXACV') } # Appeal against conviction
      let(:representation_order_date) { Date.new(2018, 03, 31).as_json }

      specify 'Case management system creates a valid scheme 9 fixed fee claim' do
        post ClaimApiEndpoints.for(:final).create, claim_params, format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: last_response_uuid)

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), fixed_fee_params.merge(claim_id: claim.uuid, fee_type_id: fixed_fee_type.id), format: :json
        expect(last_response.status).to eql 201
        expect(claim.fixed_fees.size).to eql 1
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: nil, total: 349.47, vat_amount: 69.89)

        post endpoint(:fees), misc_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_fee_type.id), format: :json
        expect(last_response.status).to eql 201
        expect(claim.misc_fees.size).to eql 1
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: nil, total: 394.47, vat_amount: 78.89)

        post endpoint(:disbursements), disbursement_params.merge(claim_id: claim.uuid, disbursement_type_id: disbursement_type.id), format: :json
        expect(last_response.status).to eql 201
        expect(claim.disbursements.size).to eql 1
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: nil, total: 494.72, vat_amount: 98.94)

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
        expect(last_response.status).to eql 201
        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
        expect(last_response.status).to eql 201
        expect(claim.expenses.size).to eql 2
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: nil, total: 1494.72, vat_amount: 298.94)
      end
    end

    context 'interim fee claim' do
      let(:case_type) { CaseType.find_by(fee_type_code: 'GRTRL') } # Trial
      let(:representation_order_date) { Date.new(2018, 03, 31).as_json }

      specify 'Case management system creates a valid scheme 9 interim (warrant) fee claim' do
        post ClaimApiEndpoints.for(:interim).create, claim_params.merge(offence_id: offence.id), format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: last_response_uuid)

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), interim_fee_params.merge(claim_id: claim.uuid, fee_type_id: interim_fee_type.id), format: :json
        expect(last_response.status).to eql 201
        expect(claim.interim_fee).to be_present
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: offence, total: 200.00, vat_amount: 40.00)

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
        expect(last_response.status).to eql 201
        expect(claim.expenses.size).to eql 2
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: offence, total: 1200.00, vat_amount: 240.00)
      end
    end

    context 'transfer fee claim' do
      let(:case_type) { CaseType.find_by(fee_type_code: 'GRTRL') } # Trial
      let(:representation_order_date) { Date.new(2018, 03, 31).as_json }

      specify 'Case management system creates a valid scheme 9 transfer fee claim' do
        post ClaimApiEndpoints.for(:transfer).create, claim_params.merge(offence_id: offence.id, **transfer_detail_params), format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: last_response_uuid)

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), transfer_fee_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201
        expect(claim.transfer_fee).to be_present
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: offence, total: 200.00, vat_amount: 40.00)

        post endpoint(:fees), misc_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_fee_type.id), format: :json
        expect(last_response.status).to eql 201

        expect(claim.misc_fees.size).to eql 1
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: offence, total: 245.00, vat_amount: 49.00)

        post endpoint(:disbursements), disbursement_params.merge(claim_id: claim.uuid, disbursement_type_id: disbursement_type.id), format: :json
        expect(last_response.status).to eql 201
        expect(claim.disbursements.size).to eql 1
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: offence, total: 345.25, vat_amount: 69.05)

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
        expect(last_response.status).to eql 201
        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
        expect(last_response.status).to eql 201
        expect(claim.expenses.size).to eql 2
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: offence, total: 1345.25, vat_amount: 269.05)
      end
    end

    # changes to interface following LGFS fixed fee calculation render this
    # the old way of creating fixed fees but we still need to handle
    # API submissions (it takes 3 months+ for vendors to change their apps).
    context 'fixed fee claim with amount' do
      let(:case_type) { CaseType.find_by(fee_type_code: 'FXACV') } # Appeal against conviction
      let(:representation_order_date) { Date.new(2018, 03, 31).as_json }

      specify 'Case management system creates a valid scheme 9 fixed fee claim' do
        post ClaimApiEndpoints.for(:final).create, claim_params, format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: last_response_uuid)

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), fixed_fee_params_with_amount.merge(claim_id: claim.uuid, fee_type_id: fixed_fee_type.id), format: :json
        expect(last_response.status).to eql 201

        expect(claim.fixed_fees.size).to eql 1
        expect(claim.fixed_fees.first.quantity).to eql 1
        expect(claim.fixed_fees.first.rate).to eql 349.47
        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: nil, total: 349.47, vat_amount: 69.89)
      end
    end

    context 'hardship claim' do
      let(:case_type) { nil }
      let(:case_stage) { create(:case_stage, :pre_ptph_or_ptph_adjourned) }
      let(:representation_order_date) { Date.new(2020, 03, 31).as_json }

      specify 'Case management system creates a valid hardship claim' do
        post ClaimApiEndpoints.for('litigators/hardship').create, claim_params.merge(case_stage_unique_code: case_stage.unique_code, offence_id: offence.id), format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: last_response_uuid)

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), graduated_fee_params.merge(claim_id: claim.uuid, fee_type_id: graduated_fee_type.id, date: representation_order_date), format: :json
        expect(last_response.status).to eql 201

        expect(claim).to be_valid_api_lgfs_claim(fee_scheme: ['LGFS', 9], offence: offence, total: 5142.87, vat_amount: 1028.57)
      end
    end
  end
end
