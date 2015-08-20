class JsonDocumentImporter

  require 'rest-client'

  attr_reader :data, :errors

  CLAIM_CREATION = 'http://localhost:3000/api/advocates/claims'
  DEFENDANT_CREATION = 'http://localhost:3000/api/advocates/defendants'
  REPRESENTATION_ORDER_CREATION = 'http://localhost:3000/api/advocates/representation_orders'
  FEE_CREATION = 'http://localhost:3000/api/advocates/fees'
  EXPENSE_CREATION = 'http://localhost:3000/api/advocates/expenses'
  DATE_ATTENDED_CREATION = 'http://localhost:3000/api/advocates/dates_attended'

  def initialize(json_file, schema)
    file = File.open(json_file)
    @data = JSON.parse(file.read)
    @errors = []
    @schema = schema
  end

  def validate!
    data.each do |claim_hash|
      @errors << JSON::Validator.fully_validate(@schema, claim_hash)
    end
    if @errors.flatten.empty?
      true
    else
      return @errors
    end
  end

  def import!
    data.each do |claim_hash|
      begin
        create_claim(claim_hash)
        get_defendants_fees_and_expenses(claim_hash)
        create_defendants_and_rep_orders
        create_expenses_or_fees_and_dates_attended(@fees, FEE_CREATION)
        create_expenses_or_fees_and_dates_attended(@expenses, EXPENSE_CREATION)
      rescue => e
        @errors << e
        claim = Claim.where(uuid: @claim_id).first # if an exception is raised the claim is destroyed along with all it's dependent objects
        claim.destroy if claim.present?
      end
    end
  end

  private

  def create_claim(claim_hash)
    params = {}
    claim_hash['claim'].each {|key, value| params[key] = value if value.class != Array}
    @claim_id = JSON.parse(RestClient.post CLAIM_CREATION, params)['id']
  end

  def get_defendants_fees_and_expenses(claim_hash)
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

  def create(attributes_hash, api_endpoint)
    params = {}
    attributes_hash.each {|key, value| params[key] = value if value.class != Array}
    @id_of_owner = JSON.parse(RestClient.post api_endpoint, params)['id']
  end

  def create_rep_orders(defendant)
    defendant['representation_orders'].each do |rep_order|
      rep_order['defendant_id'] = @id_of_owner
      RestClient.post REPRESENTATION_ORDER_CREATION, rep_order
    end
  end

  def create_expenses_or_fees_and_dates_attended(fee_or_expense_array, endpoint)
    fee_or_expense_array.each do |fee_or_expense|
      fee_or_expense['claim_id'] = @claim_id
      create(fee_or_expense, endpoint)
      create_dates_attended(fee_or_expense)
    end
  end

  def create_dates_attended(fee_or_expense)
    fee_or_expense['dates_attended'].each do |date_attended|
      date_attended['attended_item_id'] = @id_of_owner
      date_attended['attended_item_type'].capitalize!
      RestClient.post DATE_ATTENDED_CREATION, date_attended
    end
  end

end
