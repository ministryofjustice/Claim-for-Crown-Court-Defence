class JsonDocumentImporter

  require 'rest-client'

  include ActiveModel::Model
  include ActiveModel::Validations

  attr_reader :file, :data, :errors, :schema, :failed_imports, :imported_claims, :failed_schema_validation

  validates :file, presence: true
  validates :file, json_format: true

  BASE_URL                      = GrapeSwaggerRails.options.app_url
  CLAIM_CREATION                = RestClient::Resource.new BASE_URL + '/api/external_users/claims'
  DEFENDANT_CREATION            = RestClient::Resource.new BASE_URL + '/api/external_users/defendants'
  REPRESENTATION_ORDER_CREATION = RestClient::Resource.new BASE_URL + '/api/external_users/representation_orders'
  FEE_CREATION                  = RestClient::Resource.new BASE_URL + '/api/external_users/fees'
  EXPENSE_CREATION              = RestClient::Resource.new BASE_URL + '/api/external_users/expenses'
  DATE_ATTENDED_CREATION        = RestClient::Resource.new BASE_URL + '/api/external_users/dates_attended'

  def initialize(attributes = {})
    @file   = attributes[:json_file] # this expects an ActionDispatch::Http::UploadedFile object
    @errors = {}
    @schema = attributes[:schema]
    @failed_imports = []
    @imported_claims = []
    @failed_schema_validation = []
    @api_key = attributes[:api_key]
  end

  def parse_file
    temp_file = File.open(@file.tempfile)
    @data     = JSON.parse(temp_file.read)
    process_claim_hashes
    temp_file.rewind
  end

  def process_claim_hashes
    @data.each do |claim_hash|
      claim_hash.each do |claim, attributes_hash|
        delete_nils(attributes_hash)
      end
    end
  end

  def delete_nils(attributes_hash)
    attributes_hash.each do |key, value|
      case value
      when nil
        attributes_hash.delete(key)
      when Array
        value.each {|hash| delete_nils(hash) }
      end
    end
  end

  def import!
    parse_file
    data.each_with_index do |claim_hash, index|
      begin
        JSON::Validator.validate!(@schema, claim_hash)
        create_claim(claim_hash['claim'])
        set_defendants_fees_and_expenses(claim_hash['claim'])
        create_defendants_and_rep_orders
        create_fees_and_dates_attended(@fees, FEE_CREATION)
        create_expenses(@expenses, EXPENSE_CREATION)
        @imported_claims << Claim::BaseClaim.find_by(uuid: @claim_id)
      rescue ArgumentError => e
        case_number =  claim_hash['claim']['case_number'].blank? ? "Claim #{index+1} (no readable case number)" : claim_hash['claim']['case_number']
        claim_hash['claim']['case_number'] = case_number
        @failed_imports << claim_hash
        @errors[case_number] = JSON.parse(e.message).map{ |error_hash| error_hash['error'] }
        claim = Claim::BaseClaim.find_by(uuid: @claim_id) # if an exception is raised the claim is destroyed along with all its dependent objects
        claim.destroy if claim.present?
      rescue JSON::Schema::ValidationError => e
        @failed_schema_validation << claim_hash
      end

    end
  end

  private

  def create_claim(hash)
    claim_params = parse_hash(hash)
    response = CLAIM_CREATION.post(claim_params.merge(source: 'json_import')) {|response, request, result| response }
    response.code == 201 ? @claim_id = JSON.parse(response.body)['id'] : raise(ArgumentError.new(response.body))
  end

  def parse_hash(hash)
    params = {api_key: @api_key}
    hash.each {|key, value| params[key] = value if value.class != Array}
    params
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
    response = rest_client_resource.post(obj_params.merge(api_key: @api_key)) {|response, request, result| response }
    (response.code == 201 || response.code == 200) ? @id_of_owner = JSON.parse(response.body)['id'] : raise(ArgumentError.new(response.body))
  end

  def create_rep_orders(defendant)
    defendant['representation_orders'].each do |rep_order|
      rep_order['defendant_id'] = @id_of_owner
      response = REPRESENTATION_ORDER_CREATION.post(rep_order.merge(api_key: @api_key)) {|response, request, result| response }
      raise ArgumentError.new(response.body) if response.code != 201
    end
  end

  def create_fees_and_dates_attended(fee_array, rest_client_resource)
    fee_array.each do |fee|
      fee['claim_id'] = @claim_id
      create(fee, rest_client_resource)
      create_dates_attended(fee)
    end
  end

  def create_expenses(expense_array, rest_client_resource)
    expense_array.each do |expense|
      expense['claim_id'] = @claim_id
      create(expense, rest_client_resource)
    end
  end

  def create_dates_attended(fee_or_expense)
    fee_or_expense['dates_attended'].each do |date_attended|
      date_attended['attended_item_id'] = @id_of_owner
      date_attended['attended_item_type'].capitalize!
      response = DATE_ATTENDED_CREATION.post(date_attended.merge(api_key: @api_key)) {|response, request, result| response }
      raise ArgumentError.new(response.body) if response.code != 201
    end
  end

end
