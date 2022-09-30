require_relative 'base_claim_test'

class AdvocateInterimClaimTest < BaseClaimTest
  def initialize(...)
    @claim_create_endpoint = 'claims/advocates/interim'
    @email = ADVOCATE_TEST_EMAIL
    @role = 'agfs'

    super
  end

  def scheme_10_date
    @scheme_10_date ||= scheme_date_for('scheme 10')
  end

  def test_creation!
    super

    # CREATE warrant fee
    @client.post_to_endpoint('fees', warrant_fee_data)

    # CREATE miscellaneous fee
    response = @client.post_to_endpoint('fees', misc_fee_data)

    # add date attended to miscellaneous fee
    @attended_item_id = response['id']
    @client.post_to_endpoint('dates_attended', date_attended_data)

    # add expense
    @client.post_to_endpoint('expenses', expense_data)
  ensure
    clean_up
  end

  def claim_data
    advocate_category = fetch_value(ADVOCATE_CATEGORY_ENDPOINT, role: 'agfs_scheme_10')
    offence_id = fetch_id(OFFENCE_ENDPOINT, rep_order_date: scheme_10_date)
    court_id = fetch_id(COURT_ENDPOINT)

    {
      api_key:,
      creator_email: 'advocateadmin@example.com',
      advocate_email: 'advocate@example.com',
      case_number: 'S20161234',
      providers_ref: SecureRandom.uuid[3..15].upcase,
      advocate_category:,
      offence_id:,
      court_id:,
      cms_number: '12345678',
      additional_information: 'string',
      apply_vat: true
    }
  end

  def representation_order_data
    super.merge(representation_order_date: scheme_10_date)
  end

  def warrant_fee_data
    fee_type_id = fetch_id(FEE_TYPE_ENDPOINT, category: 'warrant', role: 'agfs_scheme_10')

    {
      api_key:,
      claim_id: @claim_uuid,
      fee_type_id:,
      warrant_issued_date: scheme_10_date,
      amount: 255.50
    }
  end

  def misc_fee_data
    fee_type_id = fetch_id(FEE_TYPE_ENDPOINT, category: 'misc', role: 'agfs_scheme_10')

    {
      api_key:,
      claim_id: @claim_uuid,
      fee_type_id:,
      quantity: 2,
      rate: 1.55
    }
  end

  def date_attended_data
    super.merge(date: scheme_10_date, date_to: scheme_10_date)
  end

  def expense_data
    super.merge(date: scheme_10_date)
  end
end
