require 'rails_helper'

describe JsonDocumentImporter do

  let(:schema)                  { json_schema }
  let(:importer)                { JsonDocumentImporter.new('./spec/examples/cms_exported_claim.json', schema) }
  let(:invalid_importer)        { JsonDocumentImporter.new('./spec/examples/invalid_cms_exported_claim.json', schema) }
  let(:multiple_claim_importer) { JsonDocumentImporter.new('./spec/examples/multiple_cms_exported_claims.json', schema) }
  let(:claim_params)            { {"advocate_email"=>"advocate@example.com", "case_number"=>"A12345678", "case_type_id"=>1, "indictment_number"=>"12345678", "first_day_of_trial"=>"2015-06-01", "estimated_trial_length"=>1, "actual_trial_length"=>1, "trial_concluded_at"=>"2015-06-01", "advocate_category"=>"QC", "prosecuting_authority"=>"cps", "offence_id"=>1, "court_id"=>1, "cms_number"=>"12345678", "additional_information"=>"string", "apply_vat"=>true, "trial_fixed_notice_at"=>"2015-06-01", "trial_fixed_at"=>"2015-06-01", "trial_cracked_at"=>"2015-06-01"} }
  let(:defendant_params)        { {"first_name"=>"case", "middle_name"=>"management", "last_name"=>"system", "date_of_birth"=>"1979-12-10", "order_for_judicial_apportionment"=>true, "claim_id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"} }
  let(:rep_order_params)        { {"granting_body"=>"Crown Court", "maat_reference"=>"12345678-3", "representation_order_date"=>"2015-05-01", "defendant_id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"} }
  let(:fee_params)              { {"fee_type_id"=>1, "quantity"=>1, "amount"=>1.1, "claim_id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"} }
  let(:expense_params)          { {"expense_type_id"=>1, "quantity"=>1, "rate"=>1.1, "location"=>"London", "claim_id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"} }
  let(:date_attended_params)    { {"attended_item_type"=>/Fee|Expense/, "date"=>"2015-06-01", "date_to"=>"2015-06-01", "attended_item_id"=>"1234"} }

  context 'parses a json document and' do

    context 'calls API endpoints for' do

      it 'claims, defendants, representation_orders, fees, expenses' do
        expect(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).with(claim_params).and_return({"id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"}.to_json)
        expect(JsonDocumentImporter::DEFENDANT_CREATION).to receive(:post).with(defendant_params).and_return({"id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"}.to_json)
        expect(JsonDocumentImporter::REPRESENTATION_ORDER_CREATION).to receive(:post).with(rep_order_params)
        expect(JsonDocumentImporter::FEE_CREATION).to receive(:post).with(fee_params).and_return({"id"=> "1234"}.to_json)
        expect(JsonDocumentImporter::EXPENSE_CREATION).to receive(:post).with(expense_params).and_return({"id"=> "1234"}.to_json)
        expect(JsonDocumentImporter::DATE_ATTENDED_CREATION).to receive(:post).with(date_attended_params).exactly(2).times
        importer.import!
      end

    end

    context 'each claim is processed as an atomic transaction' do
      before(:each) {
        allow(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).and_raise(API::V1::ArgumentError, 'Advocate email is invalid')
      }

      it 'and errors are stored' do
        expect(invalid_importer.errors.blank?).to be true
        invalid_importer.import!
        expect(invalid_importer.errors.blank?).to be false
        expect(invalid_importer.errors.to_s).to eq "{0=>#<API::V1::ArgumentError: Advocate email is invalid>}"
      end
    end

    context 'iterates through multiple claim hashes' do

      before(:each) {
        allow(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).and_return({"id"=>"a5c1188d-45bd-4dfd-8e72-0d04821bb30e"}.to_json)
        allow(JsonDocumentImporter::DEFENDANT_CREATION).to receive(:post).and_return({"id"=>"2be0f4b7-c095-4656-b27c-2abea40854e5"}.to_json)
        allow(JsonDocumentImporter::REPRESENTATION_ORDER_CREATION).to receive(:post)
        allow(JsonDocumentImporter::FEE_CREATION).to receive(:post).and_return({"id"=> "4e61e321-9c23-4d13-bd67-9efe51941de9"}.to_json)
        allow(JsonDocumentImporter::EXPENSE_CREATION).to receive(:post).and_return({"id"=> "690279ee-f9ad-4e0d-93d9-e37ad302f583"}.to_json)
        allow(JsonDocumentImporter::DATE_ATTENDED_CREATION).to receive(:post)
      }

      it 'to validate' do
        expect(JSON::Validator).to receive(:fully_validate).exactly(2).times
        multiple_claim_importer.validate!
        expect(multiple_claim_importer.no_errors?).to be true
      end

      it 'to create claims' do
        expect(multiple_claim_importer).to receive(:create_claim).exactly(2).times
        multiple_claim_importer.import!
        expect(multiple_claim_importer.no_errors?).to be true
      end

    end

  end

  def json_schema
    {"$schema"=>"http://json-schema.org/draft-04/schema#",
 "description"=>"Generated from Advocate Defense Payments - Claim Import with shasum 827ad7ec32160abdc3cd7075c8050812a21a64e4",
 "type"=>"object",
 "required"=>["claim"],
 "properties"=>
  {"claim"=>
    {"type"=>"object",
     "required"=>
      ["advocate_email",
       "case_number",
       "case_type_id",
       "indictment_number",
       "first_day_of_trial",
       "estimated_trial_length",
       "actual_trial_length",
       "trial_concluded_at",
       "advocate_category",
       "prosecuting_authority",
       "offence_id",
       "court_id",
       "cms_number",
       "apply_vat",
       "defendants",
       "fees",
       "expenses"],
     "properties"=>
      {"advocate_email"=>{"type"=>"string"},
       "case_number"=>{"type"=>"string"},
       "case_type_id"=>{"type"=>"integer"},
       "indictment_number"=>{"type"=>"string"},
       "first_day_of_trial"=>{"type"=>"string"},
       "estimated_trial_length"=>{"type"=>"integer"},
       "actual_trial_length"=>{"type"=>"integer"},
       "trial_concluded_at"=>{"type"=>"string"},
       "advocate_category"=>{"type"=>"string"},
       "prosecuting_authority"=>{"type"=>"string"},
       "offence_id"=>{"type"=>"integer"},
       "court_id"=>{"type"=>"integer"},
       "cms_number"=>{"type"=>"string"},
       "additional_information"=>{"type"=>"string"},
       "apply_vat"=>{"type"=>"boolean"},
       "trial_fixed_notice_at"=>{"type"=>"string"},
       "trial_fixed_at"=>{"type"=>"string"},
       "trial_cracked_at"=>{"type"=>"string"},
       "trial_cracked_at_third"=>{"type"=>"string"},
       "defendants"=>
        {"type"=>"array",
         "minItems"=>1,
         "uniqueItems"=>true,
         "items"=>
          {"type"=>"object",
           "required"=>["first_name", "middle_name", "last_name", "date_of_birth", "order_for_judicial_apportionment", "representation_orders"],
           "properties"=>
            {"claim_id"=>{"type"=>"integer"},
             "first_name"=>{"type"=>"string"},
             "middle_name"=>{"type"=>"string"},
             "last_name"=>{"type"=>"string"},
             "date_of_birth"=>{"type"=>"string"},
             "order_for_judicial_apportionment"=>{"type"=>"boolean"},
             "representation_orders"=>
              {"type"=>"array",
               "minItems"=>1,
               "uniqueItems"=>true,
               "items"=>
                {"type"=>"object",
                 "required"=>["granting_body", "maat_reference", "representation_order_date"],
                 "properties"=>
                  {"defendant_id"=>{"type"=>"integer"},
                   "granting_body"=>{"type"=>"string"},
                   "maat_reference"=>{"type"=>"string"},
                   "representation_order_date"=>{"type"=>"string"}}}}}}},
       "fees"=>
        {"type"=>"array",
         "minItems"=>1,
         "uniqueItems"=>true,
         "items"=>
          {"type"=>"object",
           "required"=>["fee_type_id", "quantity", "amount"],
           "properties"=>
            {"claim_id"=>{"type"=>"integer"},
             "fee_type_id"=>{"type"=>"integer"},
             "quantity"=>{"type"=>"integer"},
             "amount"=>{"type"=>"number"},
             "dates_attended"=>
              {"type"=>"array",
               "minItems"=>1,
               "uniqueItems"=>true,
               "items"=>
                {"type"=>"object",
                 "required"=>["attended_item_type", "date", "date_to"],
                 "properties"=>{"attended_item_id"=>{"type"=>"integer"}, "attended_item_type"=>{"type"=>"string"}, "date"=>{"type"=>"string"}, "date_to"=>{"type"=>"string"}}}}}}},
       "expenses"=>
        {"type"=>"array",
         "minItems"=>1,
         "uniqueItems"=>true,
         "items"=>
          {"type"=>"object",
           "required"=>["expense_type_id", "quantity", "rate", "location"],
           "properties"=>
            {"claim_id"=>{"type"=>"integer"},
             "expense_type_id"=>{"type"=>"integer"},
             "quantity"=>{"type"=>"integer"},
             "rate"=>{"type"=>"number"},
             "location"=>{"type"=>"string"},
             "dates_attended"=>
              {"type"=>"array",
               "minItems"=>1,
               "uniqueItems"=>true,
               "items"=>
                {"type"=>"object",
                 "required"=>["attended_item_type", "date", "date_to"],
                 "properties"=>{"attended_item_id"=>{"type"=>"integer"}, "attended_item_type"=>{"type"=>"string"}, "date"=>{"type"=>"string"}, "date_to"=>{"type"=>"string"}}}}}}}}}}}
  end

end
