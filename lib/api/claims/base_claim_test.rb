class BaseClaimTest
  attr_accessor :client, :claim_uuid

  # dropdown endpoints
  CASE_TYPE_ENDPOINT          = 'case_types'
  COURT_ENDPOINT              = 'courts'
  ADVOCATE_CATEGORY_ENDPOINT  = 'advocate_categories'
  CRACKED_THIRD_ENDPOINT      = 'trial_cracked_at_thirds'
  OFFENCE_CLASS_ENDPOINT      = 'offence_classes'
  OFFENCE_ENDPOINT            = 'offences'
  FEE_TYPE_ENDPOINT           = 'fee_types'
  EXPENSE_TYPE_ENDPOINT       = 'expense_types'
  DISBURSEMENT_TYPE_ENDPOINT  = 'disbursement_types'
  TRANSFER_STAGES_ENDPOINT    = 'transfer_stages'
  TRANSFER_CASE_CONCLUSIONS_ENDPOINT = 'transfer_case_conclusions'


  def initialize(client:)
    self.client = client
  end

  def api_key
    @api_key ||= external_user.persona.provider.api_key
  end

  def test_creation!
    raise 'implement in the subclasses'
  end

  def claim_data
    raise 'implement in the subclasses'
  end

  def agfs_schema?
    false
  end


  protected

  def puts(message)
    super("[#{self.class}] #{message}")
  end

  def external_user
    @external_user ||= begin
      email = agfs_schema? ? 'advocateadmin@example.com' : 'litigatoradmin@example.com'
      User.external_users.find_by(email: email)
    end
  end

  def supplier_number
    @supplier_number ||= external_user.persona.provider.supplier_numbers.first
  end

  def json_value_at_index(json, key=nil, index=0)
    # ignore errors as handled elsewhere
    if key
      JSON.parse(json).map { |e| e[key] }[index] rescue 0
    else
      JSON.parse(json)[index] rescue 0
    end
  end

  def id_from_json(json, key='id')
    JSON.parse(json)[key] rescue 0
  end

  def clean_up
    puts 'cleaning up'

    if (claim = Claim::BaseClaim.find_by(uuid: claim_uuid))
      if claim.destroy
        puts 'claim destroyed'
      else
        puts 'claim NOT found for destruction!'
      end
    end
  end

  def disbursement_data
    disbursement_type_id = json_value_at_index(client.get_dropdown_endpoint(DISBURSEMENT_TYPE_ENDPOINT, api_key), 'id')

    {
      "api_key": api_key,
      "claim_id": claim_uuid,
      "disbursement_type_id": disbursement_type_id,
      "net_amount": 100.25,
      "vat_amount": 20.10
    }
  end

  def warrant_fee_data
    warrant_type_id = json_value_at_index(client.get_dropdown_endpoint(FEE_TYPE_ENDPOINT, api_key, {category: 'warrant'}), 'id')

    {
      "api_key": api_key,
      "claim_id": claim_uuid,
      "fee_type_id": warrant_type_id,
      "warrant_issued_date": 1.month.ago.as_json,
      "warrant_executed_date": 1.week.ago.as_json,
      "amount": 100.25
    }
  end

  def expense_data(role:)
    expense_type_id = json_value_at_index(client.get_dropdown_endpoint(EXPENSE_TYPE_ENDPOINT, api_key, {role: role}), 'id')

    {
        "api_key": api_key,
        "claim_id": claim_uuid,
        "expense_type_id": expense_type_id,
        "rate": 1.1,
        "quantity": 1,
        "amount": 1.1,
        "location": "London",
        "reason_id": 5,
        "reason_text": "Foo",
        "date": "2016-01-01",
        "distance": 1,
        "mileage_rate_id": 1
    }
  end
end