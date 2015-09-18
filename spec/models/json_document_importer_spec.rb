require 'rails_helper'

describe JsonDocumentImporter do

  let(:schema)                            { JsonSchema.generate(JsonTemplate.generate) }
  let(:cms_exported_claim)                { double 'cms_export', tempfile: './spec/examples/cms_exported_claim.json', content_type: 'application/json'}
  let(:invalid_cms_exported_claim)        { double 'cms_export', tempfile: './spec/examples/invalid_cms_exported_claim.json', content_type: 'application/json'}
  let(:multiple_cms_exported_claims)      { double 'cms_export', tempfile: './spec/examples/multiple_cms_exported_claims.json', content_type: 'application/json'}
  let(:file_in_wrong_format)              { double 'erroneous_file_selection', tempfile: './features/examples/shorter_lorem.pdf', content_type: 'application/pdf' }
  let(:importer)                          { JsonDocumentImporter.new(json_file: cms_exported_claim, schema: schema) }
  let(:invalid_importer)                  { JsonDocumentImporter.new(json_file: invalid_cms_exported_claim, schema: schema) }
  let(:multiple_claim_importer)           { JsonDocumentImporter.new(json_file: multiple_cms_exported_claims, schema: schema) }
  let(:wrong_format_importer)             { JsonDocumentImporter.new(json_file: file_in_wrong_format, schema: schema) }
  let(:claim_params)                      { {"advocate_email"=>"advocate@example.com", "case_number"=>"A12345678", "case_type_id"=>1, "indictment_number"=>"12345678", "first_day_of_trial"=>"2015-06-01", "estimated_trial_length"=>3, "actual_trial_length"=>3, "trial_concluded_at"=>"2015-06-03", "advocate_category"=>"QC", "offence_id"=>1, "court_id"=>1, "cms_number"=>"12345678", "additional_information"=>"string", "apply_vat"=>true, "trial_fixed_notice_at"=>"2015-06-01", "trial_fixed_at"=>"2015-06-01", "trial_cracked_at"=>"2015-06-01"} }
  let(:defendant_params)                  { {"first_name"=>"case", "middle_name"=>"management", "last_name"=>"system", "date_of_birth"=>"1979-12-10", "order_for_judicial_apportionment"=>true, "claim_id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"} }
  let(:rep_order_params)                  { {"granting_body"=>"Crown Court", "maat_reference"=>"1234567891", "representation_order_date"=>"2015-05-01", "defendant_id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"} }
  let(:fee_params)                        { {"fee_type_id"=>2, "quantity"=>1, "amount"=>1.1, "claim_id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"} }
  let(:expense_params)                    { {"expense_type_id"=>1, "quantity"=>1, "rate"=>1.1, "location"=>"London", "claim_id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"} }
  let(:date_attended_params)              { {"attended_item_type"=>/Fee|Expense/, "date"=>"2015-06-01", "date_to"=>"2015-06-01", "attended_item_id"=>"1234"} }
  let(:successful_claim_response)         { double 'api_response', code: 201, body: {"id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"}.to_json }
  let(:successful_defendant_response)     { double 'api_response', code: 201, body: {"id"=>"642ec639-5037-4d64-a3aa-27c377e51ea7"}.to_json }
  let(:successful_rep_order_response)     { double 'api_response', code: 201 }
  let(:successful_fee_response)           { double 'api_response', code: 201, body: {"id"=> "1234"}.to_json }
  let(:successful_expense_response)       { double 'api_response', code: 201, body: {"id"=> "1234"}.to_json }
  let(:successful_date_attended_response) { double 'api_response', code: 201 }
  let(:failed_claim_creation)             { double 'api_error_response', code: 400, body: [{"error"=>"Advocate email is invalid"}].to_json }
  let(:failed_claim_creation2)            { double 'api_error_response', code: 400, body: [{"error"=>"Case type cannot be blank, you must select a case type"}, {"error"=>"Court cannot be blank, you must select a court"}, {"error"=>"Case number cannot be blank, you must enter a case number"}, {"error"=>"Advocate category cannot be blank, you must select an appropriate advocate category"}, {"error"=>"Offence Category cannot be blank, you must select an offence category"}].to_json }
  let(:failed_defendant_creation)         { double 'api_error_response', code: 400, body: [{"error"=> "Claim cannot be blank"}].to_json }

  context 'parses a json document and' do

    context 'calls API endpoints for' do

      it 'claims, defendants, representation_orders, fees, expenses' do
        # importer is instantiated with a json doc which contains a single, entire, claim hash.
        # it then parses the hash and sends appropriate chunks to each endpoint
        # since the import method calls each endpoint one after the other and uses the return values, mock return values are provided here (and below)
        expect(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).with(claim_params).and_return(successful_claim_response)
        expect(JsonDocumentImporter::DEFENDANT_CREATION).to receive(:post).with(defendant_params).and_return(successful_defendant_response)
        expect(JsonDocumentImporter::REPRESENTATION_ORDER_CREATION).to receive(:post).with(rep_order_params).and_return(successful_rep_order_response)
        expect(JsonDocumentImporter::FEE_CREATION).to receive(:post).with(fee_params).and_return(successful_fee_response)
        expect(JsonDocumentImporter::EXPENSE_CREATION).to receive(:post).with(expense_params).and_return(successful_expense_response)
        expect(JsonDocumentImporter::DATE_ATTENDED_CREATION).to receive(:post).with(date_attended_params).exactly(2).times.and_return(successful_date_attended_response)
        importer.import!
      end

    end

    context 'each claim is processed as an atomic transaction' do
      before(:each) {
        allow(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).and_return(failed_claim_creation)
      }

      it 'and errors are stored' do
        expect(invalid_importer.errors.blank?).to be true
        invalid_importer.import!
        expect(invalid_importer.errors.blank?).to be false
        expect(invalid_importer.errors).to eq({:claim_1=>[{"error"=>"Advocate email is invalid"}]})
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
        allow(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).and_return(successful_claim_response)
        allow(JsonDocumentImporter::DEFENDANT_CREATION).to receive(:post).and_return(successful_defendant_response)
        allow(JsonDocumentImporter::REPRESENTATION_ORDER_CREATION).to receive(:post).and_return(successful_rep_order_response)
        allow(JsonDocumentImporter::FEE_CREATION).to receive(:post).and_return(successful_fee_response)
        allow(JsonDocumentImporter::EXPENSE_CREATION).to receive(:post).and_return(successful_expense_response)
        allow(JsonDocumentImporter::DATE_ATTENDED_CREATION).to receive(:post).and_return(successful_date_attended_response)
      }

      it 'to create claims' do
        expect(multiple_claim_importer).to receive(:create_claim).exactly(2).times
        multiple_claim_importer.import!
        expect(multiple_claim_importer.errors.blank?).to be true
      end

      it 'and collates any errors - one Claim model error from each of two claims' do
        allow(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).and_return(failed_claim_creation)
        multiple_claim_importer.import!
        expect(multiple_claim_importer.errors).to eq({:claim_1=>[{"error"=>"Advocate email is invalid"}], :claim_2=>[{"error"=>"Advocate email is invalid"}]})
      end

      it 'and collates any errors - multiple Claim model errors from each of two claims' do
        allow(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).and_return(failed_claim_creation2)
        multiple_claim_importer.import!
        expect(multiple_claim_importer.errors).to eq({:claim_1=>[{"error"=>"Case type cannot be blank, you must select a case type"}, {"error"=>"Court cannot be blank, you must select a court"}, {"error"=>"Case number cannot be blank, you must enter a case number"}, {"error"=>"Advocate category cannot be blank, you must select an appropriate advocate category"}, {"error"=>"Offence Category cannot be blank, you must select an offence category"}], :claim_2=>[{"error"=>"Case type cannot be blank, you must select a case type"}, {"error"=>"Court cannot be blank, you must select a court"}, {"error"=>"Case number cannot be blank, you must enter a case number"}, {"error"=>"Advocate category cannot be blank, you must select an appropriate advocate category"}, {"error"=>"Offence Category cannot be blank, you must select an offence category"}]})
      end

      it "but stops when the first validation fail is met" do
        allow(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).and_return(failed_claim_creation)
        allow(JsonDocumentImporter::DEFENDANT_CREATION).to receive(:post).and_return(failed_defendant_creation)
        expect(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).exactly(1).times # claim creation end point is hit and returns an error
        expect(JsonDocumentImporter::DEFENDANT_CREATION).not_to receive(:post) # defendant creation is, therefore, not hit
        invalid_importer.import!
        expect(invalid_importer.errors).to eq({:claim_1 => [{"error" => "Advocate email is invalid"}]}) # claim model error is received and stored but no error is returned from defendant model
      end

    end

  end

end
