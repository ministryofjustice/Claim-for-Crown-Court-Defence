require_relative 'base_claim_test'

class DebugFinalClaimTest < BaseClaimTest
  def test_creation!
    puts 'starting'

    # create a claim
    endpoint = 'claims/final'
    puts ">>>>>>>>>>>>>> POSTING CLAIM DATA TO #{endpoint} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    puts claim_data
    response = client.post_to_endpoint('claims/final', claim_data)
    puts ">>>>>>>>>>>>>> response from #{endpoint} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    puts response
    return if client.failure

    self.claim_uuid = id_from_json(response)

    # add a defendant & rep order
    defendant_data.each_with_index do |defendant_data, index|
      response = client.post_to_endpoint_with_debug('defendants', defendant_data)
      defendant_id = id_from_json(response)
      client.post_to_endpoint_with_debug('representation_orders', representation_order_data(index, defendant_id))
    end

    # CREATE fees
    [
      {
        fee_type_id: 77,
        amount: 8153.22,
        quantity: 1250,
        date: Date.new(2016, 10, 22)
      },
      { fee_type_id: 27,
        amount: 1630.64,
        quantity: nil,
        date: Date.new(2016, 10, 22) }
    ].each do |fee_data|
      client.post_to_endpoint_with_debug('fees', fee_data.merge(api_key: api_key, claim_id: claim_uuid).to_json)
    end

    # add expense
    client.post_to_endpoint_with_debug('expenses', expense_data(role: 'lgfs'))

    # CREATE a disbursement
    client.post_to_endpoint_with_debug('disbursements', disbursement_data)
  end

  def claim_data
    case_type_id = json_value_at_index(client.get_dropdown_endpoint(CASE_TYPE_ENDPOINT, api_key, role: 'lgfs'), 'id', 12) # Trial
    offence_id = json_value_at_index(client.get_dropdown_endpoint(OFFENCE_ENDPOINT, api_key, offence_description: 'Solicitation for immoral purposes'), 'id')
    court_id = json_value_at_index(client.get_dropdown_endpoint(COURT_ENDPOINT, api_key), 'id')

    {
      "api_key": api_key,
      "creator_email": 'litigatoradmin@example.com',
      "user_email": 'litigator@example.com',
      "case_number": 'T20160111',
      "providers_ref": SecureRandom.uuid[3..15].upcase,
      "supplier_number": supplier_number,
      "case_type_id": case_type_id,
      "offence_id": offence_id,
      "court_id": court_id,
      "cms_number": 'LGFS API 7',
      "additional_information": 'This is the text case entered via rake api:specific',
      "case_concluded_at": '2016-11-22',
      "actual_trial_length": 10
    }
  end

  def defendant_data
    [
      {
        "api_key": api_key,
        "claim_id": claim_uuid,
        "first_name": 'Shankura-x',
        "last_name": 'Terhemen',
        "date_of_birth": '1979-04-13',
        "order_for_judicial_apportionment": false
      },
      {
        "api_key": api_key,
        "claim_id": claim_uuid,
        "first_name": 'Tim-x',
        "last_name": 'Terhemen',
        "date_of_birth": '1979-04-13',
        "order_for_judicial_apportionment": false
      }
    ]
  end

  def representation_order_data(index, defendant_uuid)
    raw_data = [
      {
        "api_key": api_key,
        "defendant_id": defendant_uuid,
        "maat_reference": '1012345',
        "representation_order_date": '2016-10-22'
      },
      {
        "api_key": api_key,
        "defendant_id": defendant_uuid,
        "maat_reference": '1012345',
        "representation_order_date": '2016-10-22'
      }
    ]
    raw_data[index]
  end
end
