require_relative '../../scheme_date_helpers'

class BaseClaimTest
  include SchemeDateHelpers

  # dropdown endpoints
  CASE_TYPE_ENDPOINT                 = 'case_types'.freeze
  COURT_ENDPOINT                     = 'courts'.freeze
  ADVOCATE_CATEGORY_ENDPOINT         = 'advocate_categories'.freeze
  CRACKED_THIRD_ENDPOINT             = 'trial_cracked_at_thirds'.freeze
  OFFENCE_CLASS_ENDPOINT             = 'offence_classes'.freeze
  OFFENCE_ENDPOINT                   = 'offences'.freeze
  FEE_TYPE_ENDPOINT                  = 'fee_types'.freeze
  EXPENSE_TYPE_ENDPOINT              = 'expense_types'.freeze
  DISBURSEMENT_TYPE_ENDPOINT         = 'disbursement_types'.freeze
  TRANSFER_STAGES_ENDPOINT           = 'transfer_stages'.freeze
  TRANSFER_CASE_CONCLUSIONS_ENDPOINT = 'transfer_case_conclusions'.freeze
  CASE_STAGE_ENDPOINT                = 'case_stages'.freeze

  ADVOCATE_TEST_EMAIL  = 'advocateadmin@example.com'.freeze
  LITIGATOR_TEST_EMAIL = 'litigatoradmin@example.com'.freeze

  def initialize(client:)
    @client = client
  end

  def api_key
    @api_key ||= external_user.persona.provider.api_key
  end

  def test_creation!
    puts 'starting'

    # create a claim
    response = @client.post_to_endpoint(@claim_create_endpoint, claim_data)
    return if @client.failure

    @claim_uuid = response['id']

    # add a defendant
    response = @client.post_to_endpoint('defendants', defendant_data)

    # add representation order
    @defendant_id = response['id']
    @client.post_to_endpoint('representation_orders', representation_order_data)
  end

  private

  def claim_data
    court_id = fetch_id(COURT_ENDPOINT)

    {
      api_key:,
      court_id:,
      cms_number: '12345678',
      additional_information: 'string'
    }
  end

  def puts(message)
    super("[#{self.class}] #{message}")
  end

  def external_user
    return @external_user if defined?(@external_user)

    @external_user = User.external_users.find_by(email: @email)
  end

  def supplier_number
    @supplier_number ||= external_user.persona.provider.lgfs_supplier_numbers.first.supplier_number
  end

  def fetch_id(endpoint, index: 0, key: 'id', **)
    @client.get_dropdown_endpoint(endpoint, api_key:, **).pluck(key)[index]
  end

  def fetch_value(endpoint, index: nil, **)
    response = @client.get_dropdown_endpoint(endpoint, api_key:, **)
    index = rand(response.size) if index.nil?
    response[index]
  end

  def clean_up
    puts 'cleaning up'

    return unless (claim = Claim::BaseClaim.active.find_by(uuid: @claim_uuid))
    if claim.destroy
      puts 'claim destroyed'
    else
      puts 'claim NOT found for destruction!'
    end
  end

  def defendant_data
    {
      api_key:,
      claim_id: @claim_uuid,
      first_name: 'case',
      last_name: 'management',
      date_of_birth: '1979-12-10',
      order_for_judicial_apportionment: true
    }
  end

  def representation_order_data
    {
      api_key:,
      defendant_id: @defendant_id,
      maat_reference: '4546963',
      representation_order_date: 10.years.ago.next_weekday.as_json
    }
  end

  def expense_data
    expense_type_id = fetch_id(EXPENSE_TYPE_ENDPOINT, role: @role)

    {
      api_key:,
      claim_id: @claim_uuid,
      expense_type_id:,
      amount: 500.15,
      location: 'London',
      reason_id: 5,
      reason_text: 'Foo',
      date: '2016-01-01',
      distance: 100.58,
      mileage_rate_id: 1
    }
  end
end
