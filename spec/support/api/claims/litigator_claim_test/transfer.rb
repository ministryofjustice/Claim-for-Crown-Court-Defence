require_relative 'base_claim_test'

class LitigatorTransferClaimTest < BaseClaimTest
  def initialize(...)
    @claim_create_endpoint = 'claims/transfer'
    @email = LITIGATOR_TEST_EMAIL
    @role = 'lgfs'

    super
  end

  def test_creation!
    super

    # CREATE transfer fee
    @client.post_to_endpoint('fees', transfer_fee_data)

    # CREATE a disbursement
    @client.post_to_endpoint('disbursements', disbursement_data)
  ensure
    clean_up
  end

  def claim_data
    case_type_id = fetch_id(CASE_TYPE_ENDPOINT, index: 12, role: 'lgfs') # Trial
    offence_id = fetch_id(OFFENCE_ENDPOINT, offence_description: 'Miscellaneous/other')
    court_id = fetch_id(COURT_ENDPOINT)

    transfer_stage_id = fetch_id(TRANSFER_STAGES_ENDPOINT) # 10 - Up to and including PCMH transfer
    case_conclusion_id = fetch_id(TRANSFER_CASE_CONCLUSIONS_ENDPOINT, index: 4) # 50 - Guilty plea

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
      case_concluded_at: 1.month.ago.as_json,
      'litigator_type' => 'new',
      'elected_case' => false,
      'transfer_stage_id' => transfer_stage_id,
      'transfer_date' => 1.month.ago.as_json,
      'case_conclusion_id' => case_conclusion_id
    }
  end

  def transfer_fee_data
    fee_type_id = fetch_id(FEE_TYPE_ENDPOINT, category: 'transfer')

    {
      api_key:,
      claim_id: @claim_uuid,
      fee_type_id:, # Transfer
      amount: 150.25
    }
  end
end
