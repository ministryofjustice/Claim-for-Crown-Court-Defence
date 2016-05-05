require 'rails_helper'

describe JsonDocumentImporter do

  let(:schema)                              { JsonSchema.generate }
  let(:exported_claim)                      { double 'cms_export', tempfile: './spec/examples/exported_claim.json', content_type: 'application/json'}
  let(:exported_claim_with_errors)          { double 'cms_export', tempfile: './spec/examples/exported_claim_with_errors.json', content_type: 'application/json'}
  let(:exported_claims)                     { double 'cms_export', tempfile: './spec/examples/exported_claims.json', content_type: 'application/json'}
  let(:wrong_format_file)                   { double 'erroneous_file_selection', tempfile: './features/examples/shorter_lorem.pdf', content_type: 'application/pdf' }
  let(:exported_claim_with_schema_error)    { double 'invalid_json_file', tempfile: './spec/examples/exported_claim_with_schema_error.json', content_type: 'application/json'}
  let(:exported_claim_with_nulls)           { double 'cms_export_with_nulls', tempfile: './spec/examples/exported_claim_with_nulls.json', content_type: 'application/json'}
  let(:claim_params)                        { {:source=>'json_import', 'creator_email'=>'advocateadmin@example.com', 'advocate_email'=>'advocate@example.com', 'case_number'=>'A12345678', 'case_type_id'=>1, 'first_day_of_trial'=>'2015-06-01', 'estimated_trial_length'=>3, 'actual_trial_length'=>3, 'trial_concluded_at'=>'2015-06-03', 'advocate_category'=>'QC', 'offence_id'=>1, 'court_id'=>1, 'cms_number'=>'12345678', 'additional_information'=>'string', 'apply_vat'=>true, 'trial_fixed_notice_at'=>'2015-06-01', 'trial_fixed_at'=>'2015-06-01', 'trial_cracked_at'=>'2015-06-01', api_key: 'test_key'} }
  let(:defendant_params)                    { {'first_name'=>'Angela', 'last_name'=>'Merkel', 'date_of_birth'=>'1979-12-10', 'order_for_judicial_apportionment'=>true, 'claim_id'=>'642ec639-5037-4d64-a3aa-27c377e51ea7', api_key: 'test_key'} }
  let(:rep_order_params)                    { {'maat_reference'=>'1234567891', 'representation_order_date'=>'2015-05-01', 'defendant_id'=>'642ec639-5037-4d64-a3aa-27c377e51ea7', api_key: 'test_key'} }
  let(:fee_params)                          { {'fee_type_id'=>2, 'quantity'=>1, 'rate'=>1.1, 'claim_id'=>'642ec639-5037-4d64-a3aa-27c377e51ea7', api_key: 'test_key'} }
  let(:expense_params)                      { {
                                                'expense_type_id' => 1,
                                                'quantity' => 1,
                                                'amount' => 235.46,
                                                'reason_id' => 4,
                                                'location'=>'London',
                                                'claim_id'=>'642ec639-5037-4d64-a3aa-27c377e51ea7',
                                                'date'=>'2015-06-01',
                                                api_key: 'test_key'
                                              }
                                            }
  let(:date_attended_params)                { {'attended_item_type'=>/Fee|Expense/, 'date'=>'2015-06-01', 'date_to'=>'2015-06-01', 'attended_item_id'=>'1234', api_key: 'test_key'} }
  let(:successful_claim_response)           { double 'api_response', code: 201, body: {'id'=>'642ec639-5037-4d64-a3aa-27c377e51ea7'}.to_json }
  let(:successful_defendant_response)       { double 'api_response', code: 201, body: {'id'=>'642ec639-5037-4d64-a3aa-27c377e51ea7'}.to_json }
  let(:successful_rep_order_response)       { double 'api_response', code: 201 }
  let(:successful_fee_response)             { double 'api_response', code: 201, body: {'id'=> '1234'}.to_json }
  let(:successful_expense_response)         { double 'api_response', code: 201, body: {'id'=> '1234'}.to_json }
  let(:successful_date_attended_response)   { double 'api_response', code: 201 }
  let(:failed_claim_response)               { double 'api_error_response', code: 400, body: [{'error'=>'Advocate email is invalid'}].to_json }
  let(:failed_claim_response_2)             { double 'api_error_response', code: 400, body: [{'error'=>'Case type cannot be blank, you must select a case type'}, {'error'=>'Court cannot be blank, you must select a court'}, {'error'=>'Case number cannot be blank, you must enter a case number'}, {'error'=>'Advocate category cannot be blank, you must select an appropriate advocate category'}, {'error'=>'Offence Category cannot be blank, you must select an offence category'}].to_json }
  let(:failed_defendant_response)           { double 'api_error_response', code: 400, body: [{'error'=> 'Claim cannot be blank'}].to_json }

  context 'parses a json document and' do

    let(:subject) { JsonDocumentImporter.new(json_file: exported_claim_with_nulls, schema: schema, api_key: 'test_key') }

    it 'removes attributes with NULL/nil value to prevent schema validation fail' do
      subject.parse_file
      data = subject.data
      expect(data.to_s.scan(/nil/)).to be_empty
      expect(JSON::Validator.validate!(schema, data[0])).to eq true
    end

    context 'calls API endpoints for' do

      let(:subject) { JsonDocumentImporter.new(json_file: exported_claim, schema: schema, api_key: 'test_key') }

      it 'claims, defendants, representation_orders, fees, expenses' do
        # importer is instantiated with a json doc which contains a single, entire, claim hash.
        # it then parses the hash and sends appropriate chunks to each endpoint
        # since the import method calls each endpoint one after the other and uses the return values, mock return values are provided here (and below)
        expect(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).with(claim_params).and_return(successful_claim_response)
        expect(JsonDocumentImporter::DEFENDANT_CREATION).to receive(:post).with(defendant_params).and_return(successful_defendant_response)
        expect(JsonDocumentImporter::REPRESENTATION_ORDER_CREATION).to receive(:post).with(rep_order_params).and_return(successful_rep_order_response)
        expect(JsonDocumentImporter::FEE_CREATION).to receive(:post).with(fee_params).and_return(successful_fee_response)
        expect(JsonDocumentImporter::EXPENSE_CREATION).to receive(:post).with(expense_params).and_return(successful_expense_response)
        expect(JsonDocumentImporter::DATE_ATTENDED_CREATION).to receive(:post).with(date_attended_params).exactly(1).times.and_return(successful_date_attended_response)
        subject.import!
      end

    context 'validates the data against our schema' do

      let(:subject) { JsonDocumentImporter.new(json_file: exported_claim_with_schema_error, schema: schema, api_key: 'test_key') }

      it 'and adds invalid claim hashes to an array' do
        subject.import!
        expect(subject.failed_schema_validation.count).to eq 1
      end

    end

    end

    context 'each claim is processed as an atomic transaction' do

      let(:subject) { JsonDocumentImporter.new(json_file: exported_claim_with_errors, schema: schema, api_key: 'test_key') }

      before {
        allow(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).and_return(failed_claim_response)
      }

      it 'and errors are stored' do
        expect(subject.errors.blank?).to be true
        subject.import!
        expect(subject.errors.blank?).to be false
        expect(subject.errors).to eq({'Claim 1 (no readable case number)'=>['Advocate email is invalid']})
      end
    end

    context 'can validate the json document provided' do

      context 'returning true' do
        let(:subject) { JsonDocumentImporter.new(json_file: exported_claim, schema: schema, api_key: 'test_key') }

        it 'when valid' do
          expect(subject.valid?).to eq true
        end
      end

      context 'returning false' do
        let(:subject) { JsonDocumentImporter.new(json_file: wrong_format_file, schema: schema, api_key: 'test_key') }

        it 'when invalid' do
          expect(subject.valid?).to eq false
        end
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

      context 'and creates claims' do
        let(:subject) { JsonDocumentImporter.new(json_file: exported_claims, schema: schema, api_key: 'test_key') }

        it 'from valid hashes' do
          expect(subject).to receive(:create_claim).exactly(2).times
          subject.import!
          expect(subject.errors.blank?).to be true
        end
      end

      context 'and collates errors' do

        # API calls are stubbed to return errors so the only thing that matters here is that the subject is instantiated with a document describing two claims
        let(:subject) { JsonDocumentImporter.new(json_file: exported_claims, schema: schema, api_key: 'test_key') }

        it 'one Claim model error from each of two claims' do
          allow(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).and_return(failed_claim_response)
          subject.import!
          expect(subject.errors).to eq({'A12345678'=>['Advocate email is invalid'], 'A987654321' => ['Advocate email is invalid']})
        end

        it 'multiple Claim model errors from each of two claims' do
          allow(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).and_return(failed_claim_response_2)
          subject.import!
          expect(subject.errors).to eq({
            'A12345678'=>[
              'Case type cannot be blank, you must select a case type', 
              'Court cannot be blank, you must select a court', 
              'Case number cannot be blank, you must enter a case number', 
              'Advocate category cannot be blank, you must select an appropriate advocate category', 
              'Offence Category cannot be blank, you must select an offence category'
            ], 
            'A987654321'=>[
              'Case type cannot be blank, you must select a case type',
              'Court cannot be blank, you must select a court',
              'Case number cannot be blank, you must enter a case number',
              'Advocate category cannot be blank, you must select an appropriate advocate category',
              'Offence Category cannot be blank, you must select an offence category'
            ]
          })
        end

        it 'but stops when the first validation fail is met' do
          allow(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).and_return(failed_claim_response)
          allow(JsonDocumentImporter::DEFENDANT_CREATION).to receive(:post).and_return(failed_defendant_response)
          expect(JsonDocumentImporter::CLAIM_CREATION).to receive(:post).exactly(2).times # claim creation end point is hit and returns an error
          expect(JsonDocumentImporter::DEFENDANT_CREATION).not_to receive(:post) # defendant creation is, therefore, not hit
          subject.import!
          expect(subject.errors).to eq({'A12345678' => ['Advocate email is invalid'], 'A987654321'=>['Advocate email is invalid']}) # claim model errors are received and stored but no error is returned from defendant model
        end
      end
    end

  end

end
