class JsonDocumentImporter
  require 'rest-client'

  include ActiveModel::Model
  include ActiveModel::Validations

  attr_reader :file, :data, :failed_imports, :imported_claims, :failed_schema_validation

  validate :file_parses_to_json
  validate :file_conforms_to_basic_json_schema, if: :json_data

  BASE_URL                      = GrapeSwaggerRails.options.app_url
  CLAIM_CREATION                = RestClient::Resource.new BASE_URL + '/api/external_users/claims'
  DEFENDANT_CREATION            = RestClient::Resource.new BASE_URL + '/api/external_users/defendants'
  REPRESENTATION_ORDER_CREATION = RestClient::Resource.new BASE_URL + '/api/external_users/representation_orders'
  FEE_CREATION                  = RestClient::Resource.new BASE_URL + '/api/external_users/fees'
  EXPENSE_CREATION              = RestClient::Resource.new BASE_URL + '/api/external_users/expenses'
  DATE_ATTENDED_CREATION        = RestClient::Resource.new BASE_URL + '/api/external_users/dates_attended'

  def initialize(attributes = {})
    @file = attributes[:json_file] # this expects an ActionDispatch::Http::UploadedFile object
    @schema_validator = attributes[:schema_validator]
    @api_key = attributes[:api_key]
    @failed_imports = []
    @imported_claims = []
    @failed_schema_validation = []
  end

  def process_claim_hashes
    @data = [json_data].flatten
    @data.each do |claim_hash|
      claim_hash.each_value do |attributes_hash|
        delete_nils(attributes_hash)
      end
    end
  end

  def import!
    process_claim_hashes
    @data.each.with_index(1) do |claim_hash, index|
      case_number = case_number_for(claim_hash, index)

      begin
        @schema_validator.validate_full!(claim_hash)
        create_claim_and_associations(claim_hash)
        @imported_claims << Claim::BaseClaim.active.find_by(uuid: @claim_id)
      rescue ArgumentError => ex
        claim_hash['claim']['case_number'] = case_number
        @failed_imports << claim_hash
        process_errors(case_number, ex)
        destroy_claim_if_any
      rescue JSON::Schema::ValidationError => error
        @failed_schema_validation << { case_number: case_number, error: error.message }
      end
    end
  end

  private

  def json_data
    @json_data ||= begin
                     JSON.parse(File.read(@file.tempfile))
                   rescue StandardError
                     nil
                   end
  end

  def file_parses_to_json
    json_data.present? || errors.add(:file, 'File is either not JSON or is malformed.')
  end

  # This will validate against a very basic schema to check the 'claim' object is present.
  # The main reason is for the JSON importer to not start processing the claims and to fail early,
  # giving the user error feedback similar to the 'malformed JSON' but a bit more specific.
  #
  # If this validates then there is a full validation against each of the individual claims in
  # the import! method, providing the user feedback about which claim (case_number) fails the schema.
  #
  def file_conforms_to_basic_json_schema
    @schema_validator.validate_basic!(json_data)
  rescue JSON::Schema::ValidationError => error
    errors.add(:file, error.message)
  end

  def api_key_params
    HashWithIndifferentAccess.new(api_key: @api_key)
  end

  def case_number_for(claim_hash, index)
    case_number = claim_hash.fetch('claim', {}).fetch('case_number', nil)
    case_number = "Claim #{index} (no readable case number)" if case_number.blank?
    case_number
  end

  def delete_nils(attributes_hash)
    attributes_hash.each do |key, value|
      case value
      when nil
        attributes_hash.delete(key)
      when Array
        value.each { |hash| delete_nils(hash) }
      end
    end
  end

  def process_errors(case_number, error)
    JSON.parse(error.message).each { |error_hash| errors.add(case_number, error_hash['error']) }
  rescue JSON::ParserError => jpe
    errors.add(case_number, jpe.message)
  end

  def destroy_claim_if_any
    # if an exception is raised the claim is destroyed along with all its dependent objects
    claim = Claim::BaseClaim.active.find_by(uuid: @claim_id)
    claim.destroy if claim.present?
  end

  def create_claim_and_associations(claim_hash)
    create_claim(claim_hash['claim'])
    set_defendants_fees_and_expenses(claim_hash['claim'])
    create_defendants_and_rep_orders
    create_fees_and_dates_attended(@fees, FEE_CREATION)
    create_expenses(@expenses, EXPENSE_CREATION)
  end

  def create_claim(hash)
    claim_params = parse_hash(hash)
    response = CLAIM_CREATION.post(claim_params.merge(source: 'json_import')) { |res, _request, _result| res }

    raise ArgumentError, response.body unless response.code == 201
    @claim_id = JSON.parse(response.body)['id']
  end

  def parse_hash(hash)
    params = {}
    hash.each { |key, value| params[key] = value if value.class != Array }
    params.merge(api_key_params)
  end

  def set_defendants_fees_and_expenses(claim)
    @defendants = claim['defendants']
    @fees = claim['fees']
    @expenses = claim['expenses']
  end

  def create_defendants_and_rep_orders
    @defendants.each do |defendant|
      defendant['claim_id'] = @claim_id
      create(defendant, DEFENDANT_CREATION)
      create_rep_orders(defendant)
    end
  end

  def create(attributes_hash, rest_client_resource) # used to create defendants, fees and expenses
    obj_params = parse_hash(attributes_hash)
    response = rest_client_resource.post(obj_params.merge(api_key_params)) { |res, _request, _result| res }

    raise ArgumentError, response.body unless [200, 201].include?(response.code)
    @id_of_owner = JSON.parse(response.body)['id']
  end

  def create_rep_orders(defendant)
    defendant['representation_orders'].each do |rep_order|
      rep_order['defendant_id'] = @id_of_owner
      response = REPRESENTATION_ORDER_CREATION.post(rep_order.merge(api_key_params)) { |res, _request, _result| res }
      raise ArgumentError, response.body if response.code != 201
    end
  end

  def create_fees_and_dates_attended(fee_array, rest_client_resource)
    fee_array.to_a.each do |fee|
      fee['claim_id'] = @claim_id
      create(fee, rest_client_resource)
      create_dates_attended(fee)
    end
  end

  def create_expenses(expense_array, rest_client_resource)
    expense_array.to_a.each do |expense|
      expense['claim_id'] = @claim_id
      create(expense, rest_client_resource)
    end
  end

  def create_dates_attended(fee_or_expense)
    fee_or_expense['dates_attended'].to_a.each do |date_attended|
      date_attended['attended_item_id'] = @id_of_owner
      date_attended['attended_item_type'].capitalize!
      response = DATE_ATTENDED_CREATION.post(date_attended.merge(api_key_params)) { |res, _request, _result| res }
      raise ArgumentError, response.body if response.code != 201
    end
  end
end
