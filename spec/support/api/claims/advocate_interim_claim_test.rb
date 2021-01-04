require_relative 'base_claim_test'

class AdvocateInterimClaimTest < BaseClaimTest
  def agfs_schema?
    true
  end

  def scheme_10_date
    @scheme_10_date ||= scheme_date_for('scheme 10')
  end

  def test_creation!
    puts 'starting'

    # create a claim
    response = client.post_to_endpoint('claims/advocates/interim', claim_data)
    return if client.failure

    self.claim_uuid = id_from_json(response)

    # add a defendant
    response = client.post_to_endpoint('defendants', defendant_data)

    # add representation order
    defendant_id = id_from_json(response)
    client.post_to_endpoint('representation_orders', representation_order_data(defendant_id))

    # CREATE warrant fee
    response = client.post_to_endpoint('fees', warrant_fee_data)

    # CREATE miscellaneous fee
    response = client.post_to_endpoint('fees', misc_fee_data)

    # add date attended to miscellaneous fee
    attended_item_id = id_from_json(response)
    client.post_to_endpoint('dates_attended', date_attended_data(attended_item_id, 'fee'))

    # add expense
    client.post_to_endpoint('expenses', expense_data(role: 'agfs'))
  ensure
    clean_up
  end

  def claim_data
    advocate_category = json_value_at_index(client.get_dropdown_endpoint(ADVOCATE_CATEGORY_ENDPOINT, api_key, role: 'agfs_scheme_10'))
    offence_id = json_value_at_index(client.get_dropdown_endpoint(OFFENCE_ENDPOINT, api_key, rep_order_date: scheme_10_date), 'id')
    court_id = json_value_at_index(client.get_dropdown_endpoint(COURT_ENDPOINT, api_key), 'id')

    {
      "api_key": api_key,
      "creator_email": 'advocateadmin@example.com',
      "advocate_email": 'advocate@example.com',
      "case_number": 'S20161234',
      "providers_ref": SecureRandom.uuid[3..15].upcase,
      "advocate_category": advocate_category,
      "offence_id": offence_id,
      "court_id": court_id,
      "cms_number": '12345678',
      "additional_information": 'string',
      "apply_vat": true
    }
  end

  def representation_order_data(defendant_uuid)
    {
      "api_key": api_key,
      "defendant_id": defendant_uuid,
      "maat_reference": '4546963',
      "representation_order_date": scheme_10_date
    }
  end

  def warrant_fee_data
    fee_type_id = json_value_at_index(client.get_dropdown_endpoint(FEE_TYPE_ENDPOINT, api_key, category: 'warrant', role: 'agfs_scheme_10'), 'id')

    {
      "api_key": api_key,
      "claim_id": claim_uuid,
      "fee_type_id": fee_type_id,
      "warrant_issued_date": scheme_10_date,
      "amount": 255.50
    }
  end

  def misc_fee_data
    fee_type_id = json_value_at_index(client.get_dropdown_endpoint(FEE_TYPE_ENDPOINT, api_key, category: 'misc', role: 'agfs_scheme_10'), 'id')

    {
      "api_key": api_key,
      "claim_id": claim_uuid,
      "fee_type_id": fee_type_id,
      "quantity": 2,
      "rate": 1.55
    }
  end

  def date_attended_data(attended_item_uuid, attended_item_type)
    {
      "api_key": api_key,
      "attended_item_id": attended_item_uuid,
      "attended_item_type": attended_item_type,
      "date": scheme_10_date,
      "date_to": scheme_10_date
    }
  end

  def expense_data(role:)
    expense_type_id = json_value_at_index(client.get_dropdown_endpoint(EXPENSE_TYPE_ENDPOINT, api_key, role: role), 'id')

    {
      "api_key": api_key,
      "claim_id": claim_uuid,
      "expense_type_id": expense_type_id,
      "amount": 500.15,
      "location": 'London',
      "reason_id": 5,
      "reason_text": 'Foo',
      "date": scheme_10_date,
      "distance": 100.58,
      "mileage_rate_id": 1
    }
  end
end
