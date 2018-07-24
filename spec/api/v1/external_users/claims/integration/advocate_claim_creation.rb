require 'rails_helper'
require 'api_spec_helper'
require 'support/claim_api_endpoints'

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
  let!(:court) { create(:court)}

  let(:claim_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: advocate.user.email,
      case_type_id: case_type.id,
      case_number: 'A20181234',
      providers_ref: 'A20181234/1',
      cms_number: 'Meridian',
      first_day_of_trial: "2018-04-10",
      estimated_trial_length: 10,
      actual_trial_length: 9,
      trial_concluded_at: "2018-04-19",
      advocate_category: advocate_category,
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
      date: nil,
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
      reason_text: "Foo",
      mileage_rate_id: nil,
      date: "2016-01-01T12:30:00"
    }
  end

  around do |example|
    result = example.run
    if result.is_a?(RSpec::Expectations::ExpectationNotMetError)
      puts JSON.parse(last_response.body).map{ |hash| hash['error'] }.join('\n').red
    end
  end

  context 'scheme 9' do
    context 'graduated fee case type' do
      let(:offence) { create(:offence, :with_fee_scheme_nine) }
      let(:case_type) { CaseType.find_by(fee_type_code: 'GRTRL') } # Trial
      let(:representation_order_date) { Date.new(2018, 03, 31).as_json }
      let(:advocate_category) { 'Junior alone' }

      specify "Case management system creates a valid scheme 9 graduated fee claim" do
        post ClaimApiEndpoints.for(:advocate).create, claim_params.merge(offence_id: offence.id), format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: JSON.parse(last_response.body)['id'])

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: JSON.parse(last_response.body)['id'] )

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'BABAF').id), format: :json
        expect(last_response.status).to eql 200

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'BADAF').id), format: :json
        expect(last_response.status).to eql 200

        fee = Fee::BaseFee.find_by(uuid: JSON.parse(last_response.body)['id'] )

        post endpoint(:dates_attended), date_attended_params.merge(attended_item_id: fee.uuid, date: representation_order_date), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'MIAPH').id), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'MIAHU').id), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: ExpenseType.find_by(unique_code: 'CAR').id, distance: 500.38, mileage_rate_id: 1), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: ExpenseType.find_by(unique_code: 'HOTEL').id), format: :json
        expect(last_response.status).to eql 201

        expect(claim).to be_valid
        expect(claim.fee_scheme.name).to eql 'AGFS'
        expect(claim.fee_scheme.version).to eql 9
        expect(claim.offence).to eql offence
        expect(claim.defendants.size).to eql 1
        expect(claim.defendants.first.representation_orders.size).to eql 1
        expect(claim.basic_fees.where(amount: 1..Float::INFINITY).size).to eql 2
        expect(claim.basic_fees.find_by(fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'BADAF').id).dates_attended.size).to eql 1
        expect(claim.expenses.size).to eql 2
        expect(claim.source).to eql 'api'
        expect(claim.state).to eql 'draft'
      end
    end

    context 'fixed fee case type' do
      let(:case_type) { CaseType.find_by(fee_type_code: 'FXACV') } # Appeal against conviction
      let(:representation_order_date) { Date.new(2018, 03, 31).as_json }
      let(:advocate_category) { 'Junior alone' }

      specify "Case management system creates a valid scheme 9 fixed fee claim" do
        post ClaimApiEndpoints.for(:advocate).create, claim_params, format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: JSON.parse(last_response.body)['id'])

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: JSON.parse(last_response.body)['id'] )

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'FXACV').id), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'FXACU').id), format: :json
        expect(last_response.status).to eql 201

        fee = Fee::BaseFee.find_by(uuid: JSON.parse(last_response.body)['id'] )

        post endpoint(:dates_attended), date_attended_params.merge(attended_item_id: fee.uuid, date: representation_order_date), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'MIAPH').id), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'MIAHU').id), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: ExpenseType.find_by(unique_code: 'CAR').id, distance: 500.38, mileage_rate_id: 1), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: ExpenseType.find_by(unique_code: 'HOTEL').id), format: :json
        expect(last_response.status).to eql 201

        expect(claim).to be_valid
        expect(claim.fee_scheme.name).to eql 'AGFS'
        expect(claim.fee_scheme.version).to eql 9
        expect(claim.offence).to be_nil
        expect(claim.defendants.size).to eql 1
        expect(claim.defendants.first.representation_orders.size).to eql 1
        expect(claim.fixed_fees.size).to eql 2
        expect(claim.fixed_fees.find_by(fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'FXACU').id).dates_attended.size).to eql 1
        expect(claim.expenses.size).to eql 2
        expect(claim.source).to eql 'api'
        expect(claim.state).to eql 'draft'
      end
    end
  end

  context 'scheme 10' do
    let(:offence) { create(:offence, :with_fee_scheme_ten) }
    let(:representation_order_date) { Date.new(2018, 04, 1).as_json }
    let(:advocate_category) { 'Junior' }

    context 'graduated fee case type' do
      let(:case_type) { CaseType.find_by(fee_type_code: 'GRTRL') } # Trial

      specify 'Case management system creates a valid scheme 10 graduated fee claim' do
        post ClaimApiEndpoints.for(:advocate).create, claim_params.merge(offence_id: offence.id), format: :json
        expect(last_response.status).to eql 201

        claim = Claim::BaseClaim.find_by(uuid: JSON.parse(last_response.body)['id'])

        post endpoint(:defendants), defendant_params.merge(claim_id: claim.uuid), format: :json
        expect(last_response.status).to eql 201

        defendant = Defendant.find_by(uuid: JSON.parse(last_response.body)['id'] )

        post endpoint(:representation_orders), representation_order_params.merge(defendant_id: defendant.uuid), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'BABAF').id), format: :json
        expect(last_response.status).to eql 200

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'BADAT').id), format: :json
        expect(last_response.status).to eql 200

        fee = Fee::BaseFee.find_by(uuid: JSON.parse(last_response.body)['id'] )

        post endpoint(:dates_attended), date_attended_params.merge(attended_item_id: fee.uuid, date: representation_order_date), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'MIAPH').id), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:fees), base_fee_params.merge(claim_id: claim.uuid, fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'MIAHU').id), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: ExpenseType.find_by(unique_code: 'CAR').id, distance: 500.38, mileage_rate_id: 1), format: :json
        expect(last_response.status).to eql 201

        post endpoint(:expenses), expense_params.merge(claim_id: claim.uuid, expense_type_id: ExpenseType.find_by(unique_code: 'HOTEL').id), format: :json
        expect(last_response.status).to eql 201

        expect(claim).to be_valid
        expect(claim.fee_scheme.name).to eql 'AGFS'
        expect(claim.fee_scheme.version).to eql 10
        expect(claim.offence).to eql offence
        expect(claim.defendants.size).to eql 1
        expect(claim.defendants.first.representation_orders.size).to eql 1
        expect(claim.basic_fees.where(amount: 1..Float::INFINITY).size).to eql 2
        expect(claim.basic_fees.find_by(fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'BADAT').id).dates_attended.size).to eql 1
        expect(claim.expenses.size).to eql 2
        expect(claim.source).to eql 'api'
        expect(claim.state).to eql 'draft'
      end
    end

    specify 'Case management system creates a valid scheme 10 fixed fee claim', skip: 'TODO: ' do
    end

    specify 'Case management system creates a valid scheme 10 interim/warrant fee claim', skip: 'TODO: ' do
    end
  end
end
