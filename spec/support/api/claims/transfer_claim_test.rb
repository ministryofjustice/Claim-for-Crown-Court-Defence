require_relative 'base_claim_test'

class TransferClaimTest < BaseClaimTest
  def test_creation!
    puts 'starting'

    # create a claim
    response = client.post_to_endpoint('claims/transfer', claim_data)
    return if client.failure

    self.claim_uuid = id_from_json(response)

    # add a defendant
    response = client.post_to_endpoint('defendants', defendant_data)

    # add representation order
    defendant_id = id_from_json(response)
    client.post_to_endpoint('representation_orders', representation_order_data(defendant_id))

    # CREATE transfer fee
    client.post_to_endpoint('fees', transfer_fee_data)

    # CREATE a disbursement
    client.post_to_endpoint('disbursements', disbursement_data)
  ensure
    clean_up
  end

  def claim_data
    case_type_id = json_value_at_index(client.get_dropdown_endpoint(CASE_TYPE_ENDPOINT, api_key, role: 'lgfs'), 'id', 12) # Trial
    offence_id = json_value_at_index(client.get_dropdown_endpoint(OFFENCE_ENDPOINT, api_key, offence_description: 'Miscellaneous/other'), 'id')
    court_id = json_value_at_index(client.get_dropdown_endpoint(COURT_ENDPOINT, api_key), 'id')

    transfer_stage_id = json_value_at_index(client.get_dropdown_endpoint(TRANSFER_STAGES_ENDPOINT, api_key), 'id') # 10 - Up to and including PCMH transfer
    case_conclusion_id = json_value_at_index(client.get_dropdown_endpoint(TRANSFER_CASE_CONCLUSIONS_ENDPOINT, api_key), 'id', 4) # 50 - Guilty plea

    {
      "api_key": api_key,
      "creator_email": 'litigatoradmin@example.com',
      "user_email": 'litigator@example.com',
      "case_number": 'A20161234',
      "supplier_number": supplier_number,
      "case_type_id": case_type_id,
      "offence_id": offence_id,
      "court_id": court_id,
      "cms_number": '12345678',
      "additional_information": 'string',
      "case_concluded_at": 1.month.ago.as_json,
      'litigator_type' => 'new',
      'elected_case' => false,
      'transfer_stage_id' => transfer_stage_id,
      'transfer_date' => 1.month.ago.as_json,
      'case_conclusion_id' => case_conclusion_id
    }
  end

  def transfer_fee_data
    fee_type_id = json_value_at_index(client.get_dropdown_endpoint(FEE_TYPE_ENDPOINT, api_key, category: 'transfer'), 'id')

    {
      "api_key": api_key,
      "claim_id": claim_uuid,
      "fee_type_id": fee_type_id, # Transfer
      "amount": 150.25
    }
  end
end
