require_relative 'base_claim_test'

class InterimClaimTest < BaseClaimTest

  def test_creation!
    puts 'starting'

    # create a claim
    response = client.post_to_endpoint('claims/interim', claim_data)
    return if client.failure

    self.claim_uuid = id_from_json(response)

    # add a defendant
    response = client.post_to_endpoint('defendants', defendant_data)

    # add representation order
    defendant_id = id_from_json(response)
    client.post_to_endpoint('representation_orders', representation_order_data(defendant_id))

    # CREATE interim fee
    client.post_to_endpoint('fees', interim_fee_data)

    # CREATE a disbursement
    client.post_to_endpoint('disbursements', disbursement_data)
  ensure
    clean_up
  end


  def claim_data
    # use endpoint dropdown/lookup data
    # NOTE: use case at index 12 (i.e. Trial) since this has least validations
    case_type_id = json_value_at_index(client.get_dropdown_endpoint(CASE_TYPE_ENDPOINT, api_key, {role: 'lgfs'}), 'id', 12)
    offence_id = json_value_at_index(client.get_dropdown_endpoint(OFFENCE_ENDPOINT, api_key, {offence_description: 'Miscellaneous/other'}), 'id')
    court_id = json_value_at_index(client.get_dropdown_endpoint(COURT_ENDPOINT, api_key), 'id')

    {
      "api_key": api_key,
      "creator_email": "litigatoradmin@example.com",
      "user_email": "litigator@example.com",
      "case_number": "P12345678",
      "supplier_number": supplier_number,
      "case_type_id": case_type_id,
      "offence_id": offence_id,
      "court_id": court_id,
      "cms_number": "12345678",
      "additional_information": "string",
      "effective_pcmh_date": 1.month.ago.as_json
    }
  end

  def interim_fee_data
    {
      "api_key": api_key,
      "claim_id": claim_uuid,
      "fee_type_id": 93, # Effective PCMH
      "quantity": 5,
      "amount": 200.50
    }
  end
end
