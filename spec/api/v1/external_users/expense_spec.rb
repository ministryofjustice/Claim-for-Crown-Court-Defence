require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Expense do
  include Rack::Test::Methods
  include ApiSpecHelper

  ALL_EXPENSE_ENDPOINTS = [endpoint(:expenses, :validate), endpoint(:expenses)]

  FORBIDDEN_EXPENSE_VERBS = [:get, :put, :patch, :delete]

  let(:parsed_body) { JSON.parse(last_response.body) }

  describe 'v2' do
    let(:provider) { create(:provider) }
    let(:claim) { create(:claim, source: 'api').reload }
    let(:expense_type) { create(:expense_type, :car_travel) }

    let(:params) do
      {
        api_key: provider.api_key,
        claim_id: claim.uuid,
        expense_type_id: expense_type.id,
        amount: 500.79,
        location: 'London',
        distance: 300.58,
        reason_id: 5,
        reason_text: 'Foo',
        mileage_rate_id: 1,
        date: scheme_date_for('scheme 10')
      }
    end

    context 'sending non-permitted verbs' do
      ALL_EXPENSE_ENDPOINTS.each do |endpoint| # for each endpoint
        context "to endpoint #{endpoint}" do
          FORBIDDEN_EXPENSE_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
            it "#{api_verb.upcase} should return a status of 405" do
              response = send api_verb, endpoint, format: :json
              expect(response.status).to eq 405
            end
          end
        end
      end
    end

    # Constant so we can refer to it outside of "it" blocks
    EXPENSE_FIELDS_AND_ERRORS = {
      amount: 'Enter an amount for the expense',
      claim_id: 'Claim cannot be blank',
      date: 'Enter a date for the expense',
      expense_type_id: 'Choose a type for the expense',
      reason_id: 'Enter a reason for the expense',
      distance: 'Enter the distance for the expense'
    }

    describe "POST #{endpoint(:expenses)}" do
      def post_to_create_endpoint
        post endpoint(:expenses), params, format: :json
      end

      include_examples 'should NOT be able to amend a non-draft claim'

      context 'when expense params are valid' do
        it 'creates expense, return 201 and expense JSON output including UUID' do
          post_to_create_endpoint
          expect(last_response.status).to eq 201
          json = JSON.parse(last_response.body)
          expect(json['id']).not_to be_nil
          expect(Expense.find_by(uuid: json['id']).uuid).to eq(json['id'])
          expect(Expense.find_by(uuid: json['id']).claim.uuid).to eq(json['claim_id'])
        end

        it 'creates one new expense' do
          expect { post_to_create_endpoint }.to change(Expense, :count).by(1)
        end

        it 'creates a new record using the params provided' do
          post_to_create_endpoint
          new_expense = Expense.last
          expect(new_expense.claim_id).to eq claim.id
          expect(new_expense.expense_type_id).to eq expense_type.id
          expect(new_expense.location).to eq params[:location]
          expect(new_expense.amount).to eq params[:amount]
          expect(new_expense.distance).to eq params[:distance]
        end
      end

      context 'expense_type_unique_code' do
        let(:unique_code) { expense_type.unique_code }

        it 'creates a new expense record with a expense type specified by unique code' do
          params.delete(:expense_type_id)
          params[:expense_type_unique_code] = unique_code

          post_to_create_endpoint
          expect(last_response.status).to eq 201

          new_expense = Expense.last
          expect(new_expense.claim_id).to eq claim.id
          expect(new_expense.expense_type_id).to eq expense_type.id
          expect(new_expense.location).to eq params[:location]
          expect(new_expense.amount).to eq params[:amount]
          expect(new_expense.distance).to eq params[:distance]
          expect(new_expense.expense_type.unique_code).to eq(unique_code)
        end
      end

      context 'when expense params are invalid' do
        context 'invalid API key' do
          let(:valid_params) { params }
          include_examples 'invalid API key create endpoint', exclude: :other_provider
        end

        context 'missing expected params' do
          EXPENSE_FIELDS_AND_ERRORS.each do |field, expected_message|
            it "gives the correct error message when #{field} is blank" do
              params.delete(field)
              post_to_create_endpoint
              expect(last_response.status).to eq 400
              expect(parsed_body).to include({ 'error' => expected_message })
            end
          end
        end

        context 'mutually exclusive params expense_type_id and expense_type_unique_code' do
          it 'returns an error if both are provided' do
            params[:expense_type_unique_code] = 'XXX'
            expect(params.keys).to include(:expense_type_id, :expense_type_unique_code)

            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect(last_response.body).to include('expense_type_id, expense_type_unique_code are mutually exclusive')
          end
        end

        context 'unexpected error' do
          it 'returns 400 and JSON error array of error message' do
            allow_any_instance_of(Expense).to receive(:save!).and_raise(RangeError, 'out of range for ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Integer')
            post_to_create_endpoint
            expect(last_response.status).to eq(400)
            json = JSON.parse(last_response.body)
            expect(json[0]['error']).to include('out of range for ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Integer')
          end
        end

        context 'invalid claim id' do
          it 'returns 400 and a JSON error array' do
            params[:claim_id] = SecureRandom.uuid
            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect(last_response.body).to eq '[{"error":"Claim cannot be blank"}]'
          end
        end

        context 'malformed claim UUID' do
          it 'rejects invalid uuids' do
            params[:claim_id] = 'any-old-rubbish'
            post_to_create_endpoint
            expect(last_response.status).to eq(400)
            expect(last_response.body).to eq '[{"error":"Claim cannot be blank"}]'
          end
        end

        context 'invalid expense_type_unique_code' do
          it 'returns 400 and a JSON error if no expense type was found' do
            params.delete(:expense_type_id)
            params[:expense_type_unique_code] = 'XXXXX'

            post_to_create_endpoint
            expect(last_response.status).to eq 400
            expect(last_response.body).to eq "[{\"error\":\"Couldn't find ExpenseType\"}]"
          end
        end
      end
    end

    describe "POST #{endpoint(:expenses, :validate)}" do
      def post_to_validate_endpoint
        post endpoint(:expenses, :validate), params, format: :json
      end

      it 'valid requests should return 200 and String true' do
        post_to_validate_endpoint
        expect(last_response.status).to eq 200
        json = JSON.parse(last_response.body)
        expect(json).to eq({ 'valid' => true })
      end

      context 'invalid API key' do
        let(:valid_params) { params }
        include_examples 'invalid API key validate endpoint', exclude: :other_provider
      end

      context 'missing expected params' do
        EXPENSE_FIELDS_AND_ERRORS.each do |field, expected_message|
          it "gives the correct error message when #{field} is blank" do
            params.delete(field)
            post_to_validate_endpoint
            expect(last_response.status).to eq 400
            expect(parsed_body).to include({ 'error' => expected_message })
          end
        end
      end

      it 'invalid claim id should return 400 and a JSON error array' do
        params[:claim_id] = SecureRandom.uuid
        post_to_validate_endpoint
        expect(last_response.status).to eq 400
        expect(last_response.body).to eq '[{"error":"Claim cannot be blank"}]'
      end
    end
  end
end
