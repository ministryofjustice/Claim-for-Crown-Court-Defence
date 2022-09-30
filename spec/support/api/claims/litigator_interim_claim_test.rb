require_relative 'base_claim_test'

class LitigatorInterimClaimTest < BaseClaimTest
  def initialize(...)
    @claim_create_endpoint = 'claims/interim'
    @email = LITIGATOR_TEST_EMAIL

    super
  end

  def test_creation!
    super

    # CREATE interim fee
    @client.post_to_endpoint('fees', interim_fee_data)

    # CREATE a disbursement
    @client.post_to_endpoint('disbursements', disbursement_data)
  ensure
    clean_up
  end

  def claim_data
    case_type_id = json_value_at_index(@client.get_dropdown_endpoint(CASE_TYPE_ENDPOINT, api_key, role: 'lgfs'), 'id', 12) # Trial
    offence_id = json_value_at_index(@client.get_dropdown_endpoint(OFFENCE_ENDPOINT, api_key, offence_description: 'Miscellaneous/other'), 'id')
    court_id = json_value_at_index(@client.get_dropdown_endpoint(COURT_ENDPOINT, api_key), 'id')

    {
      api_key:,
      creator_email: 'litigatoradmin@example.com',
      user_email: 'litigator@example.com',
      case_number: 'A20161234',
      supplier_number:,
      case_type_id:,
      offence_id:,
      court_id:,
      cms_number: '12345678',
      additional_information: 'string',
      effective_pcmh_date: 1.month.ago.as_json
    }
  end

  def interim_fee_data
    fee_type_id = json_value_at_index(@client.get_dropdown_endpoint(FEE_TYPE_ENDPOINT, api_key, category: 'interim'), 'id', 1) # Effective PCMH

    {
      api_key:,
      claim_id: @claim_uuid,
      fee_type_id:,
      quantity: 5,
      amount: 200.50
    }
  end
end
