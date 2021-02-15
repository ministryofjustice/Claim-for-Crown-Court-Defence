module ApiSpecHelper
  ENDPOINTS = {
    defendants: '/api/external_users/defendants',
    representation_orders: '/api/external_users/representation_orders',
    fees: '/api/external_users/fees',
    dates_attended: '/api/external_users/dates_attended',
    expenses: '/api/external_users/expenses',
    disbursements: '/api/external_users/disbursements'
  }.freeze

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def endpoint(association, validate = nil)
      endpoint = ENDPOINTS[association.to_sym]
      return endpoint + '/validate' if validate
      endpoint
    end
  end

  def endpoint(association, validate = nil)
    self.class.endpoint(association, validate)
  end

  def expect_validate_success_response
    expect(last_response.status).to eq 200
    json = JSON.parse(last_response.body)
    expect(json).to eq({ 'valid' => true })
  end

  def expect_error_response(message)
    expect(last_response.status).to eq(400)
    json = JSON.parse(last_response.body)
    expect(json.map { |row| row['error'] }).to include(message)
  end

  def expect_unauthorised_error(message = 'Unauthorised')
    expect(last_response.status).to eq(401)
    json = JSON.parse(last_response.body)
    expect(json[0]['error']).to eql(message)
  end

  def last_response_uuid
    JSON.parse(last_response.body)['id']
  end
end
