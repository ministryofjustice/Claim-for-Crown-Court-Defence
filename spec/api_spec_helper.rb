module ApiSpecHelper

  def expect_validate_success_response
    expect(last_response.status).to eq 200
    json = JSON.parse(last_response.body)
    expect(json).to eq({ "valid" => true })
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

end