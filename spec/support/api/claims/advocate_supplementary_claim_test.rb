require_relative 'base_claim_test'

class AdvocateSupplementaryClaimTest < BaseClaimTest
  def agfs_schema?
    true
  end

  def test_creation!
    puts 'starting'

    # create a claim
    response = client.post_to_endpoint('claims/advocates/supplementary', claim_data)
    return if client.failure

    self.claim_uuid = response['id']

    # add a defendant
    response = client.post_to_endpoint('defendants', defendant_data)

    # add representation order
    defendant_id = response['id']
    client.post_to_endpoint('representation_orders', representation_order_data(defendant_id))

    # CREATE miscellaneous fee
    response = client.post_to_endpoint('fees', misc_fee_data)

    # add date attended to miscellaneous fee
    attended_item_id = response['id']
    client.post_to_endpoint('dates_attended', date_attended_data(attended_item_id, 'fee'))

    # add expense
    client.post_to_endpoint('expenses', expense_data(role: 'agfs'))
  ensure
    clean_up
  end

  def claim_data
    client.get_dropdown_endpoint(CASE_TYPE_ENDPOINT, api_key, role: 'agfs') # Trial
    advocate_category = json_value_at_index(client.get_dropdown_endpoint(ADVOCATE_CATEGORY_ENDPOINT, api_key))
    client.get_dropdown_endpoint(OFFENCE_ENDPOINT, api_key)
    court_id = json_value_at_index(client.get_dropdown_endpoint(COURT_ENDPOINT, api_key), 'id')
    client.get_dropdown_endpoint(CRACKED_THIRD_ENDPOINT, api_key)

    {
      api_key:,
      creator_email: 'advocateadmin@example.com',
      advocate_email: 'advocate@example.com',
      case_number: 'B20161234',
      providers_ref: SecureRandom.uuid[3..15].upcase,
      advocate_category:,
      court_id:,
      cms_number: '12345678',
      additional_information: 'string',
      apply_vat: true
    }
  end

  def misc_fee_data
    # Only certain misc fees are eligible e.g. Confiscation hearings (half day) - MIDTH
    fee_type_id = json_value_at_index(client.get_dropdown_endpoint(FEE_TYPE_ENDPOINT, api_key, category: 'misc', role: 'agfs', unique_code: 'MIDTH'), 'id')

    {
      api_key:,
      claim_id: claim_uuid,
      fee_type_id:,
      quantity: 2,
      rate: 1.55
    }
  end
end
