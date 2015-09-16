require 'rails_helper'

describe JsonDocumentImporter do

  let(:schema)                        { JsonSchema.generate(JsonTemplate.generate) }
  let(:cms_exported_claim)            { double 'cms_export', tempfile: './spec/examples/cms_exported_claim.json', content_type: 'application/json'}
  let(:invalid_cms_exported_claim)    { double 'cms_export', tempfile: './spec/examples/invalid_cms_exported_claim.json', content_type: 'application/json'}
  let(:multiple_cms_exported_claims)  { double 'cms_export', tempfile: './spec/examples/multiple_cms_exported_claims.json', content_type: 'application/json'}
  let(:file_in_wrong_format)          { double 'erroneous_file_selection', tempfile: './features/examples/shorter_lorem.pdf', content_type: 'application/pdf' }
  let(:importer)                      { JsonDocumentImporter.new(json_file: cms_exported_claim, schema: schema) }
  let(:invalid_importer)              { JsonDocumentImporter.new(json_file: invalid_cms_exported_claim, schema: schema) }
  let(:multiple_claim_importer)       { JsonDocumentImporter.new(json_file: multiple_cms_exported_claims, schema: schema) }
  let(:wrong_format_importer)         { JsonDocumentImporter.new(json_file: file_in_wrong_format, schema: schema) }
  let(:claim_params)                  { {"advocate_email"=>"advocate@example.com", "case_number"=>"A12345678", "case_type_id"=>1, "indictment_number"=>"12345678", "first_day_of_trial"=>"2015-06-01", "estimated_trial_length"=>3, "actual_trial_length"=>3, "trial_concluded_at"=>"2015-06-03", "advocate_category"=>"QC", "prosecuting_authority"=>"cps", "offence_id"=>1, "court_id"=>1, "cms_number"=>"12345678", "additional_information"=>"string", "apply_vat"=>true, "trial_fixed_notice_at"=>"2015-06-01", "trial_fixed_at"=>"2015-06-01", "trial_cracked_at"=>"2015-06-01"} }
  let(:defendant_params)              { {"first_name"=>"case", "middle_name"=>"management", "last_name"=>"system", "date_of_birth"=>"1979-12-10", "order_for_judicial_apportionment"=>true, "claim_id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"} }
  let(:rep_order_params)              { {"granting_body"=>"Crown Court", "maat_reference"=>"7894561358", "representation_order_date"=>"2015-05-01", "defendant_id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"} }
  let(:fee_params)                    { {"fee_type_id"=>2, "quantity"=>1, "amount"=>1.1, "claim_id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"} }
  let(:expense_params)                { {"expense_type_id"=>1, "quantity"=>1, "rate"=>1.1, "location"=>"London", "claim_id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"} }
  let(:date_attended_params)          { {"attended_item_type"=>/Fee|Expense/, "date"=>"2015-06-01", "date_to"=>"2015-06-01", "attended_item_id"=>"1234"} }

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

    context 'can validate the json document provided' do

      it 'returning true if valid' do
        expect(importer.valid?).to eq true
      end

      it 'returning false if the file format is not json' do
        expect(wrong_format_importer.valid?).to eq false
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

      it 'to create claims' do
        expect(multiple_claim_importer).to receive(:create_claim).exactly(2).times
        multiple_claim_importer.import!
        expect(multiple_claim_importer.errors.blank?).to be true
      end

    end

  end

end
