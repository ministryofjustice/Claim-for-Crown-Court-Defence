class JsonDocumentImporter

  require 'rest-client'

  include ActiveModel::Model
  include ActiveModel::Validations

  attr_reader :file, :data, :errors, :schema, :failed_imports, :imported_claims

  validates :file, presence: true
  validates :file, json_format: true

  BASE_URL                      = GrapeSwaggerRails.options.app_url
  CLAIM_CREATION                = RestClient::Resource.new BASE_URL + '/api/advocates/claims'
  CLAIM_VALIDATION              = RestClient::Resource.new BASE_URL + '/api/advocates/claims/validate'
  DEFENDANT_CREATION            = RestClient::Resource.new BASE_URL + '/api/advocates/defendants'
  REPRESENTATION_ORDER_CREATION = RestClient::Resource.new BASE_URL + '/api/advocates/representation_orders'
  FEE_CREATION                  = RestClient::Resource.new BASE_URL + '/api/advocates/fees'
  EXPENSE_CREATION              = RestClient::Resource.new BASE_URL + '/api/advocates/expenses'
  DATE_ATTENDED_CREATION        = RestClient::Resource.new BASE_URL + '/api/advocates/dates_attended'

  def initialize(attributes = {})
    @file   = attributes[:json_file]
    @errors = {}
    @schema = attributes[:schema]
    @failed_imports = []
    @imported_claims = []
  end

  def parse_file
    temp_file = File.open(@file.tempfile)
    @data     = JSON.parse(temp_file.read)
    temp_file.rewind
  end

  def import!
    parse_file
    data.each_with_index do |claim_hash, index|
      begin
        create_claim(claim_hash)
        set_defendants_fees_and_expenses(claim_hash)
        create_defendants_and_rep_orders
        create_expenses_or_fees_and_dates_attended(@fees, FEE_CREATION)
        create_expenses_or_fees_and_dates_attended(@expenses, EXPENSE_CREATION)
        @imported_claims << Claim.find_by(uuid: @claim_id)
      rescue => e
        @failed_imports << claim_hash
        @errors["claim_#{index + 1}".to_sym] = JSON.parse(e.message)
        claim = Claim.find_by(uuid: @claim_id) # if an exception is raised the claim is destroyed along with all its dependent objects
        claim.destroy if claim.present?
      end
    end
  end

  private

  def create_claim(claim_hash)
    claim_params = {}
    claim_hash['claim'].each {|key, value| claim_params[key] = value if value.class != Array}
    response = CLAIM_CREATION.post(claim_params) {|response, request, result| response }
    if response.code == 201
      @claim_id = JSON.parse(response.body)['id']
    else
      raise ArgumentError.new(response.body)
    end
  end

  def set_defendants_fees_and_expenses(claim_hash)
    @defendants = claim_hash['claim']['defendants']
    @fees = claim_hash['claim']['fees']
    @expenses = claim_hash['claim']['expenses']
  end

  def create_defendants_and_rep_orders
    @defendants.each do |defendant|
      defendant['claim_id'] = @claim_id
      create(defendant, DEFENDANT_CREATION)
      create_rep_orders(defendant)
    end
  end

  def create(attributes_hash, rest_client_resource)
    obj_params = {}
    attributes_hash.each {|key, value| obj_params[key] = value if value.class != Array}
    response = rest_client_resource.post(obj_params) {|response, request, result| response }
    if response.code == 201
      @id_of_owner = JSON.parse(response.body)['id']
    else
      raise ArgumentError.new(response.body)
    end
  end

  def create_rep_orders(defendant)
    defendant['representation_orders'].each do |rep_order|
      rep_order['defendant_id'] = @id_of_owner
      response = REPRESENTATION_ORDER_CREATION.post(rep_order) {|response, request, result| response }
      if response.code != 201
        raise ArgumentError.new(response.body)
      end
    end
  end

  def create_expenses_or_fees_and_dates_attended(fee_or_expense_array, rest_client_resource)
    fee_or_expense_array.each do |fee_or_expense|
      fee_or_expense['claim_id'] = @claim_id
      create(fee_or_expense, rest_client_resource)
      create_dates_attended(fee_or_expense)
    end
  end

  def create_dates_attended(fee_or_expense)
    fee_or_expense['dates_attended'].each do |date_attended|
      date_attended['attended_item_id'] = @id_of_owner
      date_attended['attended_item_type'].capitalize!
      response = DATE_ATTENDED_CREATION.post(date_attended) {|response, request, result| response }
      if response.code != 201
        raise ArgumentError.new(response.body)
      end
    end
  end

end
