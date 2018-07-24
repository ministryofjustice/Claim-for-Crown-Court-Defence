module ApiSpecHelper
  # TODO: use these constants everywhere and wrap for validate equivalents
  ENDPOINTS = {
    defendants: '/api/external_users/defendants',
    representation_orders: '/api/external_users/representation_orders',
    fees: '/api/external_users/fees',
    dates_attended: '/api/external_users/dates_attended',
    expenses: '/api/external_users/expenses',
    disbursements: '/api/external_users/disbursements'
  }.freeze

  def expect_validate_success_response
    expect(last_response.status).to eq 200
    json = JSON.parse(last_response.body)
    expect(json).to eq({ 'valid' => true })
  end

 def expect_error_response(message, idx=0)
    expect(last_response.status).to eq(400)
    json = JSON.parse(last_response.body)
    expect(json[idx]['error']).to include(message)
  end

  def expect_unauthorised_error(message = 'Unauthorised')
    expect(last_response.status).to eq(401)
    json = JSON.parse(last_response.body)
    expect(json[0]['error']).to eql(message)
  end

  def endpoint(association)
    ENDPOINTS[association.to_sym]
  end
end