require_relative 'base_claim_test'

class LitigatorHardshipClaimTest < BaseClaimTest
  def test_creation!
    puts 'starting'

    # create a claim
    response = client.post_to_endpoint('claims/litigators/hardship', claim_data)
    return if client.failure

    self.claim_uuid = id_from_json(response)

    # add a defendant
    response = client.post_to_endpoint('defendants', defendant_data)

    # add representation order
    defendant_id = id_from_json(response)
    client.post_to_endpoint('representation_orders', representation_order_data(defendant_id))

    # CREATE graduated fee
    client.post_to_endpoint('fees', graduated_fee_data)
  ensure
    clean_up
  end

  def claim_data
    offence_id = json_value_at_index(client.get_dropdown_endpoint(OFFENCE_ENDPOINT, api_key, offence_description: 'Miscellaneous/other'), 'id')
    court_id = json_value_at_index(client.get_dropdown_endpoint(COURT_ENDPOINT, api_key), 'id')

    {
      "api_key": api_key,
      "creator_email": 'litigatoradmin@example.com',
      "user_email": 'litigator@example.com',
      "case_number": 'A20201234',
      "supplier_number": supplier_number,
      "case_stage_unique_code": 'PREPTPHADJ',
      "offence_id": offence_id,
      "court_id": court_id,
      "cms_number": '12345678',
      "additional_information": 'string',
      "effective_pcmh_date": 1.month.ago.as_json
    }
  end

  def graduated_fee_data
    fee_type_id = json_value_at_index(client.get_dropdown_endpoint(FEE_TYPE_ENDPOINT, api_key, category: 'graduated', role: 'lgfs'), 'id', 5) # Trial

    {
      "api_key": api_key,
      "claim_id": claim_uuid,
      "fee_type_id": fee_type_id,
      "quantity": 5,
      "amount": 100.25,
      "date": 1.month.ago.as_json
    }
  end
end
