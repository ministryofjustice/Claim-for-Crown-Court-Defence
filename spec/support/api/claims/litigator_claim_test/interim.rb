require_relative 'base_claim_test'

class LitigatorInterimClaimTest < BaseClaimTest
  def initialize(...)
    @claim_create_endpoint = 'claims/interim'
    @email = LITIGATOR_TEST_EMAIL
    @role = 'lgfs'

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
    case_type_id = fetch_id(CASE_TYPE_ENDPOINT, index: 12, role: 'lgfs') # Trial
    offence_id = fetch_id(OFFENCE_ENDPOINT, offence_description: 'Miscellaneous/other')
    court_id = fetch_id(COURT_ENDPOINT)

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
    fee_type_id = fetch_id(FEE_TYPE_ENDPOINT, index: 1, category: 'interim') # Effective PCMH

    {
      api_key:,
      claim_id: @claim_uuid,
      fee_type_id:,
      quantity: 5,
      amount: 200.50
    }
  end
end
