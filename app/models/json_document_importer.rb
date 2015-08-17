class JsonDocumentImporter

  require 'rest-client'

  attr_reader :data

  def initialize(json_file)
    file = File.open(json_file)
    @data = JSON.parse(file.read)
  end

  def import!
    @data.each do |claim_hash|
      set_claim_details(claim_hash)
      create_claim
      get_details_of_all_defendants(claim_hash)
      create_defendants_and_rep_orders
      get_details_of_all_fees(claim_hash)
      create_fees_and_dates_attended
      get_details_of_all_expenses(claim_hash)
      create_expenses_and_dates_attended
    end
  end

  def set_claim_details(claim_hash)
    @claim_details = HashWithIndifferentAccess.new
    claim_hash['claim'].each do |key, value|
      @claim_details[key] = value if value.class != Array
    end
    @claim_details
  end

  def create_claim
    begin
      @claim_id = JSON.parse(RestClient.post 'http://localhost:3000/api/advocates/claims', @claim_details)['id']
    rescue => e
      puts e.response
    end
  end

  def get_details_of_all_defendants(claim_hash)
    @defendants = claim_hash['claim']['defendants']
  end

  def create_defendants_and_rep_orders
    @defendants.each do |defendant|
      defendant['claim_id'] = @claim_id
      create_defendant(defendant)
      create_rep_orders(defendant)
    end
  end

  def create_defendant(defendant)
    data = {}
    defendant.each {|key, value| data[key] = value if value.class != Array}
    begin
      @defendant_id = JSON.parse(RestClient.post 'http://localhost:3000/api/advocates/defendants', data)['id']
    rescue => e
      puts e.response
    end
  end

  def create_rep_orders(defendant)
    defendant['representation_orders'].each do |rep_order|
    rep_order['defendant_id'] = @defendant_id
      begin
        RestClient.post 'http://localhost:3000/api/advocates/representation_orders', rep_order
      rescue => e
        puts e.response
      end
    end
  end

  def get_details_of_all_fees(claim_hash)
    @fees = claim_hash['claim']['fees']
  end

  def create_fees_and_dates_attended
    @fees.each do |fee|
      fee['claim_id'] = @claim_id
      create_fee(fee)
      create_fee_dates_attended(fee)
    end
  end

  def create_fee(fee)
    data = {}
    fee.each {|key, value| data[key] = value if value.class != Array}
    begin
      @fee_id = JSON.parse(RestClient.post 'http://localhost:3000/api/advocates/fees', data)['id']
    rescue => e
      puts e.response
    end
  end

  def create_fee_dates_attended(fee)
    fee['dates_attended'].each do |date_attended|
      date_attended['attended_item_id'] = @fee_id
      date_attended['attended_item_type'] = 'Fee'
      begin
        RestClient.post 'http://localhost:3000/api/advocates/dates_attended', date_attended
      rescue => e
        puts e.response
      end
    end
  end

  def get_details_of_all_expenses(claim_hash)
    @expenses = claim_hash['claim']['expenses']
  end

  def create_expenses_and_dates_attended
    @expenses.each do |expense|
      expense['claim_id'] = @claim_id
      create_expense(expense)
      create_expense_dates_attended(expense)
    end
  end

  def create_expense(expense)
    data = {}
    expense.each {|key, value| data[key] = value if value.class != Array}
    begin
      @expense_id = JSON.parse(RestClient.post 'http://localhost:3000/api/advocates/expenses', data)['id']
    rescue => e
      puts e.response
    end
  end

  def create_expense_dates_attended(expense)
    expense['dates_attended'].each do |date_attended|
      date_attended['attended_item_id'] = @expense_id
      date_attended['attended_item_type'] = 'Expense'
      begin
        RestClient.post 'http://localhost:3000/api/advocates/dates_attended', date_attended
      rescue => e
        puts e.response
      end
    end
  end

end
