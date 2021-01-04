require 'rails_helper'

RSpec::Matchers.define :be_valid_api_agfs_claim do |expected|
  match do |claim|
    @results = results(claim)
    @results.values.map { |arr| arr.uniq.length.eql?(1) }.all?
  end

  def results_hash
    { valid: [], fee_scheme: [], offence: [], source: [], state: [], defendant_count: [], representation_orders_count: [], total: [] }
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

RSpec.shared_examples 'scheme 9 advocate final claim' do |options|
  let(:offence) { create(:offence, :with_fee_scheme_nine) }

  context "graduated fee claim on #{ClaimApiEndpoints.for(options[:relative_endpoint]).create}" do
    let(:case_type) { CaseType.find_by(fee_type_code: 'GRTRL') } # Trial

    specify 'Case management system creates a valid scheme 9 graduated fee claim' do
      post ClaimApiEndpoints.for(options[:relative_endpoint]).create, claim_params.merge(offence_id: offence.id), format: :json
      expect(last_response.status).to eql 201

      claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

      post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
      expect(last_response.status).to eql 201

      defendant = Defendant.find_by(uuid: last_response_uuid)

      post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: basic_fee.id), format: :json
      expect(last_response.status).to eql 200

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: daily_attendance_3.id), format: :json
      expect(last_response.status).to eql 200

      fee = Fee::BaseFee.find_by(uuid: last_response_uuid)

      post endpoint(:dates_attended), date_attended_params.merge(attended_item_id: fee.uuid, date: representation_order_date.as_json), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_fee.id), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_uplift.id), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
      expect(last_response.status).to eql 201

      expect(claim).to be_valid_api_agfs_claim(fee_scheme: ['AGFS', 9], offence: offence, total: 1840.2)
      expect(claim.basic_fees.where(amount: 1..Float::INFINITY).size).to eql 2
      expect(claim.basic_fees.find_by(fee_type_id: daily_attendance_3.id).dates_attended.size).to eql 1
      expect(claim.expenses.size).to eql 2
    end
  end

  context "fixed fee claim on #{ClaimApiEndpoints.for(options[:relative_endpoint]).create}" do
    let(:case_type) { CaseType.find_by(fee_type_code: 'FXACV') } # Appeal against conviction

    specify 'Case management system creates a valid scheme 9 fixed fee claim' do
      post ClaimApiEndpoints.for(:advocate).create, claim_params.except(:first_day_of_trial, :estimated_trial_length, :actual_trial_length,:trial_concluded_at), format: :json
      expect(last_response.status).to eql 201

      claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

      post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
      expect(last_response.status).to eql 201

      defendant = Defendant.find_by(uuid: last_response_uuid)

      post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: fixed_fee.id), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: fixed_uplift.id), format: :json
      expect(last_response.status).to eql 201

      fee = Fee::BaseFee.find_by(uuid: last_response_uuid)

      post endpoint(:dates_attended), date_attended_params.merge(attended_item_id: fee.uuid, date: representation_order_date.as_json), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_fee.id), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_uplift.id), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
      expect(last_response.status).to eql 201

      expect(claim).to be_valid_api_agfs_claim(fee_scheme: ['AGFS', 9], offence: nil, total: 1840.2)
      expect(claim.fixed_fees.size).to eql 2
      expect(claim.fixed_fees.find_by(fee_type_id: fixed_uplift.id).dates_attended.size).to eql 1
      expect(claim.expenses.size).to eql 2
    end
  end
end

RSpec.shared_examples 'scheme 10 advocate final claim' do |options|
  let(:offence) { create(:offence, :with_fee_scheme_ten) }

  context "graduated fee claim on #{ClaimApiEndpoints.for(options[:relative_endpoint]).create}" do
    let(:case_type) { CaseType.find_by(fee_type_code: 'GRTRL') } # Trial

    specify 'Case management system creates a valid scheme 10 graduated fee claim' do
      post ClaimApiEndpoints.for(options[:relative_endpoint]).create, claim_params.merge(offence_id: offence.id), format: :json
      expect(last_response.status).to eql 201

      claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

      post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
      expect(last_response.status).to eql 201

      defendant = Defendant.find_by(uuid: last_response_uuid)

      post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: basic_fee.id), format: :json
      expect(last_response.status).to eql 200

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: daily_attendance_2.id), format: :json
      expect(last_response.status).to eql 200

      fee = Fee::BaseFee.find_by(uuid: last_response_uuid)

      post endpoint(:dates_attended), date_attended_params.merge(attended_item_id: fee.uuid, date: representation_order_date.as_json), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_fee.id), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_uplift.id), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
      expect(last_response.status).to eql 201

      expect(claim).to be_valid_api_agfs_claim(fee_scheme: ['AGFS', 10], offence: offence, total: 1840.2)
      expect(claim.basic_fees.where(amount: 1..Float::INFINITY).size).to eql 2
      expect(claim.basic_fees.find_by(fee_type_id: daily_attendance_2.id).dates_attended.size).to eql 1
      expect(claim.expenses.size).to eql 2
    end
  end

  context "fixed fee claim on #{ClaimApiEndpoints.for(options[:relative_endpoint]).create}" do
    let(:case_type) { CaseType.find_by(fee_type_code: 'FXACV') } # Appeal against conviction
    let(:advocate_category) { 'Junior' }

    specify 'Case management system creates a valid scheme 10 fixed fee claim' do
      post ClaimApiEndpoints.for(:advocate).create, claim_params.except(:first_day_of_trial, :estimated_trial_length, :actual_trial_length,:trial_concluded_at), format: :json
      expect(last_response.status).to eql 201

      claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

      post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
      expect(last_response.status).to eql 201

      defendant = Defendant.find_by(uuid: last_response_uuid)

      post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: fixed_fee.id), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: fixed_uplift.id), format: :json
      expect(last_response.status).to eql 201

      fee = Fee::BaseFee.find_by(uuid: last_response_uuid)

      post endpoint(:dates_attended), date_attended_params.merge(attended_item_id: fee.uuid, date: representation_order_date.as_json), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_fee.id), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_uplift.id), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
      expect(last_response.status).to eql 201

      expect(claim).to be_valid_api_agfs_claim(fee_scheme: ['AGFS', 10], offence: nil, total: 1840.2)
      expect(claim).to be_instance_of Claim::AdvocateClaim
      expect(claim.fixed_fees.size).to eql 2
      expect(claim.fixed_fees.find_by(fee_type_id: fixed_uplift.id).dates_attended.size).to eql 1
      expect(claim.expenses.size).to eql 2
    end
  end
end

RSpec.shared_examples 'scheme 12 advocate final claim' do |options|
  let(:offence) { create(:offence, :with_fee_scheme_twelve, offence_band: offence_band, offence_class: nil) }
  let(:offence_band) { create(:offence_band, offence_category: offence_category) }
  let(:offence_category) { create(:offence_category, number: 2) }
  let(:miscellaneous_fee) { Fee::BaseFeeType.find_by(unique_code: 'MIPHC') }

  context "graduated fee claim on #{ClaimApiEndpoints.for(options[:relative_endpoint]).create}" do
    let(:case_type) { CaseType.find_by(fee_type_code: 'GRTRL') } # Trial

    specify 'Case management system creates a valid scheme 12 graduated fee claim' do
      post ClaimApiEndpoints.for(options[:relative_endpoint]).create, claim_params.merge(offence_id: offence.id), format: :json
      expect(last_response.status).to eql 201

      claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

      post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
      expect(last_response.status).to eql 201

      defendant = Defendant.find_by(uuid: last_response_uuid)
      post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: basic_fee.id), format: :json
      expect(last_response.status).to eql 200

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: daily_attendance_2.id), format: :json
      expect(last_response.status).to eql 200

      fee = Fee::BaseFee.find_by(uuid: last_response_uuid)

      post endpoint(:dates_attended), date_attended_params.merge(attended_item_id: fee.uuid, date: representation_order_date.as_json), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_fee.id), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
      expect(last_response.status).to eql 201

      expect(claim).to be_valid_api_agfs_claim(fee_scheme: ['AGFS', 12], offence: offence, total: 1630.2)
      expect(claim.basic_fees.where(amount: 1..Float::INFINITY).size).to eql 2
      expect(claim.basic_fees.find_by(fee_type_id: daily_attendance_2.id).dates_attended.size).to eql 1
      expect(claim.misc_fees.size).to eql 1
      expect(claim.misc_fees.first.fee_type.unique_code).to eql 'MIPHC'
      expect(claim.expenses.size).to eql 2
    end
  end

  context "fixed fee claim on #{ClaimApiEndpoints.for(options[:relative_endpoint]).create}" do
    let(:case_type) { CaseType.find_by(fee_type_code: 'FXACV') } # Appeal against conviction
    let(:advocate_category) { 'Junior' }

    specify 'Case management system creates a valid scheme 12 fixed fee claim' do
      post ClaimApiEndpoints.for(:advocate).create, claim_params.except(:first_day_of_trial, :estimated_trial_length, :actual_trial_length,:trial_concluded_at), format: :json
      expect(last_response.status).to eql 201

      claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

      post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
      expect(last_response.status).to eql 201

      defendant = Defendant.find_by(uuid: last_response_uuid)
      post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: fixed_fee.id), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: fixed_uplift.id), format: :json
      expect(last_response.status).to eql 201

      fee = Fee::BaseFee.find_by(uuid: last_response_uuid)

      post endpoint(:dates_attended), date_attended_params.merge(attended_item_id: fee.uuid, date: representation_order_date.as_json), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_fee.id), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
      expect(last_response.status).to eql 201

      post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
      expect(last_response.status).to eql 201

      expect(claim).to be_valid_api_agfs_claim(fee_scheme: ['AGFS', 12], offence: nil, total: 1630.2)
      expect(claim).to be_instance_of Claim::AdvocateClaim
      expect(claim.fixed_fees.size).to eql 2
      expect(claim.fixed_fees.find_by(fee_type_id: fixed_uplift.id).dates_attended.size).to eql 1
      expect(claim.misc_fees.size).to eql 1
      expect(claim.misc_fees.first.fee_type.unique_code).to eql 'MIPHC'
      expect(claim.expenses.size).to eql 2
    end
  end
end

RSpec.describe 'API claim creation for AGFS' do
  include Rack::Test::Methods
  include ApiSpecHelper

  before do
    seed_fee_schemes
    seed_case_types
    seed_fee_types
    seed_expense_types
  end

  let!(:provider) { create(:provider) }
  let!(:other_provider) { create(:provider) }
  let!(:vendor) { create(:external_user, :admin, provider: provider) }
  let!(:advocate) { create(:external_user, :advocate, provider: provider) }
  let!(:court) { create(:court) }

  let(:basic_fee) { Fee::BaseFeeType.find_by(unique_code: 'BABAF') }
  let(:daily_attendance_3) { Fee::BaseFeeType.find_by(unique_code: 'BADAF') }
  let(:daily_attendance_2) { Fee::BaseFeeType.find_by(unique_code: 'BADAT') }
  let(:fixed_fee) { Fee::BaseFeeType.find_by(unique_code: 'FXACV') }
  let(:fixed_uplift) { Fee::BaseFeeType.find_by(unique_code: 'FXNOC') }
  let(:miscellaneous_fee) { Fee::BaseFeeType.find_by(unique_code: 'MIAPH') }
  let(:miscellaneous_uplift) { Fee::BaseFeeType.find_by(unique_code: 'MIAHU') }
  let(:expense_car) { ExpenseType.find_by(unique_code: 'CAR') }
  let(:expense_hotel) { ExpenseType.find_by(unique_code: 'HOTEL') }

  let(:claim_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: advocate.user.email,
      case_type_id: case_type&.id,
      case_number: 'A20181234',
      providers_ref: 'A20181234/1',
      cms_number: 'Meridian',
      first_day_of_trial: representation_order_date.as_json,
      estimated_trial_length: 10,
      actual_trial_length: 9,
      trial_concluded_at: (representation_order_date + 9.days).as_json,
      advocate_category: advocate_category,
      offence_id: nil,
      court_id: court.id,
      additional_information: 'Bish bosh bash',
      prosecution_evidence: true
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
        representation_order_date: representation_order_date.as_json,
        maat_reference: '2320006'
    }
  end

  let(:base_fee_params) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      fee_type_id: nil,
      quantity: 1,
      rate: 210.00
    }
  end

  let(:date_attended_params) do
    {
      api_key: provider.api_key,
      attended_item_id: nil,
      date: nil
    }
  end

  let(:expense_params) do
    {
      api_key: provider.api_key,
      claim_id: nil,
      expense_type_id: nil,
      amount: 500.10,
      location: 'London',
      distance: nil,
      reason_id: 5,
      reason_text: 'Foo',
      mileage_rate_id: nil,
      date: representation_order_date.as_json
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

  context 'scheme 9' do
    let(:representation_order_date) { Date.new(2018, 03, 31).beginning_of_day }
    let(:advocate_category) { 'Junior alone' }

    context 'final fee claims' do
      include_context 'deactivate deprecation warnings'
      include_examples 'scheme 9 advocate final claim', relative_endpoint: :advocate
      include_examples 'scheme 9 advocate final claim', relative_endpoint: 'advocates/final'
    end
  end

  context 'scheme 10' do
    let(:representation_order_date) { Date.new(2018, 04, 1).beginning_of_day }
    let(:advocate_category) { 'Junior' }

    context 'final fee claims' do
      include_context 'deactivate deprecation warnings'
      include_examples 'scheme 10 advocate final claim', relative_endpoint: :advocate
      include_examples 'scheme 10 advocate final claim', relative_endpoint: 'advocates/final'
    end

    context 'warrant fee claim' do
      let(:case_type) { nil }
      let(:offence) { create(:offence, :with_fee_scheme_ten) }
      let(:advocate_category) { 'Junior' }

      specify 'Case management system creates a valid scheme 10 interim/warrant fee claim' do
        post ClaimApiEndpoints.for('advocates/interim').create, claim_params.merge(offence_id: offence.id).except(:first_day_of_trial, :estimated_trial_length, :actual_trial_length, :trial_concluded_at), format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: last_response_uuid)

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'WARR').id, warrant_issued_date: representation_order_date.as_json, rate: nil, amount: 210.0), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
        expect(last_response.status).to eql 201

        expect(claim).to be_valid_api_agfs_claim(fee_scheme: ['AGFS', 10], offence: offence, total: 1210.2)
        expect(claim).to be_instance_of Claim::AdvocateInterimClaim
        expect(claim.warrant_fee).to be_present
        expect(claim.expenses.size).to eql 2
      end
    end

    context 'supplementary fee claim' do
      let(:case_type) { nil }
      let(:offence) { nil }
      let(:miscellaneous_fee) { Fee::BaseFeeType.find_by(unique_code: 'MIDTH') } # Confiscation hearings (half day)
      let(:miscellaneous_uplift) { Fee::BaseFeeType.find_by(unique_code: 'MIDHU') } # Confiscation hearings (half day uplift)

      specify 'Case management system creates a valid scheme 10 supplementary fee claim' do
        post ClaimApiEndpoints.for('advocates/supplementary').create, claim_params.except(:first_day_of_trial, :estimated_trial_length, :actual_trial_length, :trial_concluded_at), format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: last_response_uuid)

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_fee.id), format: :json
        expect(last_response.status).to eql 201

        fee = Fee::BaseFee.find_by(uuid: last_response_uuid)

        post endpoint(:dates_attended), date_attended_params.merge(attended_item_id: fee.uuid, date: representation_order_date.as_json), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_uplift.id), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
        expect(last_response.status).to eql 201

        expect(claim).to be_valid_api_agfs_claim(fee_scheme: ['AGFS', 10], offence: nil, total: 1420.2)
        expect(claim).to be_instance_of Claim::AdvocateSupplementaryClaim
        expect(claim.misc_fees.size).to eql 2
        expect(claim.misc_fees.find_by(fee_type_id: miscellaneous_fee.id).dates_attended.size).to eql 1
        expect(claim.expenses.size).to eql 2
      end
    end

    context 'hardship fee claim' do
      let(:case_type) { nil }
      let(:case_stage) { create(:case_stage, :trial_not_concluded) }
      let(:offence) { create(:offence, :with_fee_scheme_ten) }
      let(:miscellaneous_fee) { Fee::BaseFeeType.find_by(unique_code: 'MIDTH') } # Confiscation hearings (half day)
      let(:miscellaneous_uplift) { Fee::BaseFeeType.find_by(unique_code: 'MIDHU') } # Confiscation hearings (half day uplift)

      specify 'Case management system creates a valid hardship claim' do
        post ClaimApiEndpoints.for('advocates/hardship').create, claim_params.merge(offence_id: offence.id, case_stage_unique_code: case_stage.unique_code), format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: last_response_uuid)

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: last_response_uuid)

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: basic_fee.id), format: :json
        expect(last_response.status).to eql 200

        fee = Fee::BaseFee.find_by(uuid: last_response_uuid)

        post endpoint(:dates_attended), date_attended_params.merge(attended_item_id: fee.uuid, date: representation_order_date.as_json), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: miscellaneous_uplift.id), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_car.id, distance: 500.38, mileage_rate_id: 1), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: expense_hotel.id), format: :json
        expect(last_response.status).to eql 201

        expect(claim).to be_valid_api_agfs_claim(fee_scheme: ['AGFS', 10], offence: offence, total: 1420.2)
        expect(claim).to be_instance_of Claim::AdvocateHardshipClaim
      end
    end
  end

  context 'scheme 12' do
    let(:representation_order_date) { Settings.clar_release_date.beginning_of_day }
    let(:advocate_category) { 'Junior' }

    context 'final fee claims' do
      around do |example|
        travel_to(Settings.clar_release_date.beginning_of_day + 5.hours) do
          example.run
        end
      end

      include_context 'deactivate deprecation warnings'
      include_examples 'scheme 12 advocate final claim', relative_endpoint: :advocate
      include_examples 'scheme 12 advocate final claim', relative_endpoint: 'advocates/final'
    end
  end
end
