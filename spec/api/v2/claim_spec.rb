require 'rails_helper'
require 'spec_helper'
require 'api_spec_helper'
require 'support/claim_api_endpoints'

describe API::V2::Claim do
  include Rack::Test::Methods
  include ApiSpecHelper

  after(:all) { clean_database }

  before(:all) do
    @claim = create(:deterministic_claim, :redetermination)
  end

  def do_request(claim_uuid: @claim.uuid, api_key: @claim.external_user.user.api_key)
    get "/api/claims/#{claim_uuid}", {api_key: api_key}, {format: :json}
  end

  def get_full_claim
    response = do_request
    expect(response.status).to eq 200

    body = JSON.parse(response.body, symbolize_names: true)
    expect(body).to have_key(:claim)

    normalise_ids!(body[:claim])
  end

  def normalise_ids!(hash)
    return unless hash.is_a?(Hash)

    hash.each do |_key, value|
      normalise_ids!(value) if value.is_a?(Hash)
      value.map { |h| normalise_ids!(h) } if value.is_a?(Array)
    end

    hash.merge!(id: 1) if hash.key?(:id)
    hash.merge!(uuid: 'uuid') if hash.key?(:uuid)
    hash.merge!(sender_uuid: 'uuid') if hash.key?(:sender_uuid)
    hash
  end

  describe 'GET claim/:uuid' do
    it 'should return 406 Not Acceptable if requested API version via header is not supported' do
      header 'Accept-Version', 'v1'

      do_request
      expect(last_response.status).to eq 406
      expect(last_response.body).to include('The requested version is not supported.')
    end

    it 'should require an API key' do
      do_request(api_key: nil)
      expect(last_response.status).to eq 401
      expect(last_response.body).to include('Unauthorised')
    end

    context 'claim not found' do
      it 'should respond not found when claim is not found' do
        do_request(claim_uuid: '123-456-789')
        expect(last_response.status).to eq 404
        expect(last_response.body).to include('Claim not found')
      end
    end

    it 'should return a JSON with the required information' do
      claim = get_full_claim
      expect(claim.keys).to eq([:claim_details, :case_details, :defendants, :fees, :expenses, :disbursements, :documents, :messages, :assessment, :redeterminations])
    end

    context 'should return the expected details' do
      it 'claim details' do
        details = get_full_claim[:claim_details]
        expect(details.to_json).to eq '{"uuid":"uuid","type":"Claim::AdvocateClaim","provider_code":"XY666","advocate_category":"QC","additional_information":"This is some important additional information.","apply_vat":true,"state":"redetermination","submitted_at":"2016-03-10T11:44:55Z","originally_submitted_at":"2016-03-10T11:44:55Z","authorised_at":"2016-03-10T11:44:55Z","created_by":{"id":1,"uuid":"uuid","first_name":"John","last_name":"Smith","email":"john.smith@example.com"},"external_user":{"id":1,"uuid":"uuid","first_name":"John","last_name":"Smith","email":"john.smith@example.com"}}'
      end

      it 'case details' do
        details = get_full_claim[:case_details]
        expect(details.to_json).to eq '{"case_type":"Fixed fee","case_number":"Z12345678","source":"web","cms_number":"CMS-12345","providers_reference":"reference-123","court":{"id":1,"code":"ABC","name":"Acme Court","court_type":"crown"},"transfer_court":{"court":{"id":1,"code":"ZZZ","name":"Northern Court","court_type":"crown"},"case_number":"X12345678"},"offence":{"category":"Miscellaneous/other","class":"C: Lesser offences involving violence or damage and less serious drug offences"},"trial_dates":{"date_started":null,"date_concluded":null,"estimated_length":0,"actual_length":0},"retrial_dates":{"date_started":null,"date_concluded":null,"estimated_length":0,"actual_length":0},"cracked_dates":{"date_fixed_notice":null,"date_fixed":null,"date_cracked":null,"date_cracked_at_third":null},"effective_pcmh_date":null,"legal_aid_transfer_date":null,"totals":{"fees":25.0,"expenses":9.99,"disbursements":0.0,"vat_amount":6.13,"total":34.99},"evidence_documents":["LAC1 - memo of conviction","Representation order"]}'
      end

      it 'defendants details' do
        details = get_full_claim[:defendants]
        expect(details.to_json).to eq '[{"id":1,"uuid":"uuid","first_name":"Kaia","last_name":"Casper","date_of_birth":"1995-06-20T00:00:00Z","representation_orders":[{"id":1,"uuid":"uuid","maat_reference":"1234567890","date":"2016-01-10T00:00:00Z"}]}]'
      end

      it 'fees details' do
        details = get_full_claim[:fees]
        expect(details.to_json).to eq '[{"type":"Pages of prosecution evidence","code":"PPE","date":null,"quantity":1.0,"amount":25.0,"rate":0.0,"dates_attended":[]}]'
      end

      it 'expenses details' do
        details = get_full_claim[:expenses]
        expect(details.to_json).to eq '[{"date":"2016-01-10T00:00:00Z","type":"Car travel","location":"Brighton","mileage_rate":"45p","reason":"Pre-trial conference expert witnesses","distance":27.0,"hours":0.0,"quantity":0.0,"rate":0.0,"net_amount":9.99,"vat_amount":0.0}]'
      end

      # Advocate claims do not have disbursements, tested separated in /spec/api/entities/disbursement_spec.rb
      it 'disbursements details' do
        details = get_full_claim[:disbursements]
        expect(details.to_json).to eq '[]'
      end

      it 'documents details' do
        details = get_full_claim[:documents]
        expect(details.to_json).to eq '[{"uuid":"uuid","url":"assets/test/images/longer_lorem.pdf","file_name":"longer_lorem.pdf","size":49993}]'
      end

      it 'messages details' do
        details = get_full_claim[:messages]
        expect(details.to_json).to eq '[{"created_at":"2016-03-10T11:44:55Z","sender_uuid":"uuid","body":"This is the message body.","document":{"url":"assets/test/images/shorter_lorem.docx","file_name":"shorter_lorem.docx","size":14713}}]'
      end

      it 'assessment details' do
        details = get_full_claim[:assessment]
        expect(details.to_json).to eq '{"created_at":"2016-03-10T11:44:55Z","totals":{"fees":24.2,"expenses":8.5,"disbursements":0.0,"vat_amount":5.72,"total":32.7}}'
      end

      it 'redeterminations details' do
        details = get_full_claim[:redeterminations]
        expect(details.to_json).to eq '[{"created_at":"2016-03-10T11:44:55Z","totals":{"fees":25.0,"expenses":9.2,"disbursements":0.0,"vat_amount":5.99,"total":34.2}}]'
      end
    end
  end
end
