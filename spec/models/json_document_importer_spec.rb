require 'rails_helper'

describe JsonDocumentImporter, vcr: true do

  let(:schema)                  { json_schema }
  let(:importer)                { JsonDocumentImporter.new('./spec/examples/cms_exported_claim.json', schema) }
  let(:invalid_importer)        { JsonDocumentImporter.new('./spec/examples/invalid_cms_exported_claim.json', schema) }
  let(:multiple_claim_importer) { JsonDocumentImporter.new('./spec/examples/multiple_cms_exported_claims.json', schema) }
  let(:test_id)                 { '1234' }

  context 'parses a json document and' do

    context 'calls API endpoints for' do

      before(:each) {
        allow(RestClient).to receive(:post).and_return({'id' => test_id}.to_json)
      }

      it 'claims' do
        expect(RestClient).to receive(:post).with("http://localhost:3000/api/advocates/claims", {"advocate_email"=>"advocate@example.com", "case_number"=>"12345678", "case_type_id"=>1, "indictment_number"=>"12345678", "first_day_of_trial"=>"2015/06/01", "estimated_trial_length"=>1, "actual_trial_length"=>1, "trial_concluded_at"=>"2015/06/02", "advocate_category"=>"QC", "prosecuting_authority"=>"cps", "offence_id"=>1, "court_id"=>1, "cms_number"=>"12345678", "additional_information"=>"string", "apply_vat"=>true, "trial_fixed_notice_at"=>"2015-06-01", "trial_fixed_at"=>"2015-06-01", "trial_cracked_at"=>"2015-06-01"})
        importer.import!
      end

      it 'defendants' do
        expect(RestClient).to receive(:post).with("http://localhost:3000/api/advocates/defendants", {"claim_id"=>'1234', "first_name"=>"case", "middle_name"=>"management", "last_name"=>"system", "date_of_birth"=>"1979/12/10", "order_for_judicial_apportionment"=>true})
        importer.import!
      end

      it 'representation_orders' do
        expect(RestClient).to receive(:post).with("http://localhost:3000/api/advocates/representation_orders", {"defendant_id"=>'1234', "granting_body"=>"Crown Court", "maat_reference"=>"12345678", "representation_order_date"=>"2015/05/01"})
        importer.import!
      end

      it 'fees' do
        expect(RestClient).to receive(:post).with("http://localhost:3000/api/advocates/fees", {"claim_id"=>'1234', "fee_type_id"=>75, "quantity"=>1, "amount"=>1.1})
        importer.import!
      end

      it 'expenses' do
        expect(RestClient).to receive(:post).with("http://localhost:3000/api/advocates/expenses", {"claim_id"=>'1234', "expense_type_id"=>1, "quantity"=>1, "rate"=>1.1, "location"=>"London"})
        importer.import!
      end

      it 'dates_attended' do
        # one for the fee
        expect(RestClient).to receive(:post).with("http://localhost:3000/api/advocates/dates_attended", {"attended_item_id"=>'1234', "attended_item_type"=>"Fee", "date"=>"2015/06/01", "date_to"=>"2015/06/01"})
        # one for the expense
        expect(RestClient).to receive(:post).with("http://localhost:3000/api/advocates/dates_attended", {"attended_item_id"=>'1234', "attended_item_type"=>"Expense", "date"=>"2015/06/01", "date_to"=>"2015/06/01"})
        importer.import!
      end
      
    end

    context 'each claim is processed as an atomic transaction' do

      it 'and errors are stored' do
        expect(invalid_importer.errors.blank?).to be true
        invalid_importer.import!
        expect(invalid_importer.errors.blank?).to be false
      end

    end

    context 'can validate the json document against our schema' do

      it 'returning true if valid' do
        expect(importer.validate!).to eq true
      end

    end

    context 'iterates through multiple claim hashes' do

      it 'to validate' do
        expect(JSON::Validator).to receive(:fully_validate).exactly(2).times
        multiple_claim_importer.validate!
      end

      it 'to create claims' do
        expect(multiple_claim_importer).to receive(:create_claim).exactly(2).times
        multiple_claim_importer.import!
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
