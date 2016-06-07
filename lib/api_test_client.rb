# class used to smoke test the Restful API
#
# The claim creation process uses the dropdown data endpoints
# thereby double checking that those endpoints are working and
# their values are valid for claim creation or assoicated records.
#
# example:
# ---------------------------------------
#   api_client = ApiTestClient.new()
#   api_client.run
#   if api_client.failure
#     puts "failed"
#     puts api_client.errors.join("/n")
#     OR
#     puts api_client.full_error_messages.join("/n") # still needs work
#   end
# ---------------------------------------
#

require 'rest-client'

class ApiTestClient
  DROPDOWN_PREFIX = 'api'
  EXTERNAL_USER_PREFIX = 'api/external_users'

  # dropdown endpoints
  CASE_TYPE_ENDPOINT          = "case_types"
  COURT_ENDPOINT              = "courts"
  ADVOCATE_CATEGORY_ENDPOINT  = "advocate_categories"
  CRACKED_THIRD_ENDPOINT      = "trial_cracked_at_thirds"
  OFFENCE_CLASS_ENDPOINT      = "offence_classes"
  OFFENCE_ENDPOINT            = "offences"
  FEE_TYPE_ENDPOINT           = "fee_types"
  EXPENSE_TYPE_ENDPOINT       = "expense_types"

  ALL_DROPDOWN_ENDPOINTS      = [CASE_TYPE_ENDPOINT,
                                COURT_ENDPOINT,
                                ADVOCATE_CATEGORY_ENDPOINT,
                                CRACKED_THIRD_ENDPOINT,
                                OFFENCE_CLASS_ENDPOINT,
                                OFFENCE_ENDPOINT,
                                FEE_TYPE_ENDPOINT,
                                EXPENSE_TYPE_ENDPOINT
                                ]

  def initialize
    @errors = []
    @full_error_messages = []
    @messages = []
    @success = true
  end

  def run
    # retrieve api key
    @api_key = test_provider_api_key

    test_dropdown_endpoints
    test_claim_creation_endpoints
  end

  def success
    @success
  end

  def failure
    !@success
  end

  def errors
    @errors
  end

  def full_error_messages
    @full_error_messages
  end

  def messages
    @messages
  end

private

  def api_root_url
    GrapeSwaggerRails.options.app_url
  end

  def json_value_at_index(json, key=nil,index=0)
    # ignore errors as handled elsewhere
    if key
      JSON.parse(json).map{ |e| e[key] }[index] rescue 0
    else
      JSON.parse(json)[index] rescue 0
    end
  end

  def id_from_json(json,key='id')
    JSON.parse(json)[key] rescue 0
  end

  #
  # don't raise exceptions but, instead, return the
  # response for analysis.
  #
  def get_dropdown_endpoint(resource, prefix=nil)
    endpoint = RestClient::Resource.new([api_root_url, prefix || DROPDOWN_PREFIX, resource].join('/') <<  "?api_key=#{@api_key}" )
    endpoint.get do |response, request, _result|
      if response.code.to_s =~ /^2/
        @messages << "#{resource} Endpoint returned success code - #{response.code}"
      else
        @success = false
        @errors << "#{resource} Endpoint raised error - #{response.code}"
        @full_error_messages << "#{resource} Endpoint raised error - #{response}"
      end
      response
    end
  end

  def test_dropdown_endpoints
    ALL_DROPDOWN_ENDPOINTS.each do |resource|
      get_dropdown_endpoint(resource)
    end
  end

  def clean_up
      puts "smoke test: cleaning up"
      claim = Claim::BaseClaim.find_by(uuid: @claim_id)
      if claim
        if claim.destroy
          puts "smoke test: claim destroyed"
        else
          puts "smoke test: claim NOT found for destruction!!"
        end
      end
  end

  def test_provider_api_key
    user = User.external_users.find_by(email: 'advocateadmin@example.com')
    user.persona.provider.api_key
  end

  def post_to_advocate_endpoint(resource, payload, prefix=nil)
    endpoint = RestClient::Resource.new([api_root_url, prefix || EXTERNAL_USER_PREFIX, resource].join('/'))
    endpoint.post(payload, { :content_type => :json, :accept => :json } ) do |response, request, _result|
      if response.code.to_s =~ /^2/
        @messages << "#{resource} Endpoint returned success code - #{response.code}"
      else
        @success = false
        @errors << "#{resource} Endpoint raised error - #{response.code}"
        @full_error_messages << "#{resource} Endpoint raised error - #{response}"
      end
      response
    end
  end

  def test_claim_creation_endpoints

    # create a claim
    response = post_to_advocate_endpoint('claims', claim_data)
    return if failure

    @claim_id = id_from_json(response)

    # add a defendant
    response = post_to_advocate_endpoint('defendants', defendant_data(@claim_id))

    # add representation order
    defendant_id = id_from_json(response)
    post_to_advocate_endpoint('representation_orders', representation_order_data(defendant_id))

    # UPDATE basic fee
    post_to_advocate_endpoint('fees', basic_fee_data(@claim_id))

    # CREATE miscellaneous fee
    response = post_to_advocate_endpoint('fees', misc_fee_data(@claim_id))

    # add date attended to miscellaneous fee
    attended_item_id = id_from_json(response)
    post_to_advocate_endpoint('dates_attended', date_attended_data(attended_item_id,"fee"))

    # add expense
    response = post_to_advocate_endpoint('expenses', expense_data(@claim_id))

  ensure
    clean_up

  end

  def claim_data

    # use endpoint dropdown/lookup data
    # NOTE: use case type 12 at index 11 (i.e. Trial) since this has least validations
    case_type_id            = json_value_at_index(get_dropdown_endpoint(CASE_TYPE_ENDPOINT),'id',11)
    advocate_category       = json_value_at_index(get_dropdown_endpoint(ADVOCATE_CATEGORY_ENDPOINT))
    offence_id              = json_value_at_index(get_dropdown_endpoint(OFFENCE_ENDPOINT),'id')
    court_id                = json_value_at_index(get_dropdown_endpoint(COURT_ENDPOINT),'id')
    trial_cracked_at_third  = json_value_at_index(get_dropdown_endpoint(CRACKED_THIRD_ENDPOINT))

    {
      "api_key": @api_key,
      "creator_email": "advocateadmin@example.com",
      "advocate_email": "advocate@example.com",
      "case_number": "P12345678",
      "case_type_id": case_type_id,
      "first_day_of_trial": "2015-06-01",
      "estimated_trial_length": 1,
      "actual_trial_length": 1,
      "trial_concluded_at": "2015-06-02",
      "advocate_category": advocate_category,
      "offence_id": offence_id,
      "court_id": court_id,
      "cms_number": "12345678",
      "additional_information": "string",
      "apply_vat": true,
      "trial_fixed_notice_at": "2015-06-01",
      "trial_fixed_at": "2015-06-01",
      "trial_cracked_at": "2015-06-01",
      "trial_cracked_at_third": trial_cracked_at_third
      }
  end

  def defendant_data(claim_uuid)
    {
      "api_key": @api_key,
      "claim_id": claim_uuid,
      "first_name": "case",
      "last_name": "management",
      "date_of_birth": "1979-12-10",
      "order_for_judicial_apportionment": true,
    }
  end

  def representation_order_data(defendant_uuid)
    {
      "api_key": @api_key,
      "defendant_id": defendant_uuid,
      "maat_reference": "4546963741",
      "representation_order_date": "2015-05-21"
    }
  end

  def expense_data(claim_uuid)

    expense_type_id = json_value_at_index(get_dropdown_endpoint(EXPENSE_TYPE_ENDPOINT),'id')

    {
      "api_key": @api_key,
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

  def basic_fee_data(claim_uuid)

    fee_type_id = json_value_at_index(get_dropdown_endpoint(FEE_TYPE_ENDPOINT),'id', 10)

    {
      "api_key": @api_key,
      "claim_id": claim_uuid,
      "fee_type_id": fee_type_id,
      "quantity": 1,
    }
  end


  def misc_fee_data(claim_uuid)

    fee_type_id = json_value_at_index(get_dropdown_endpoint(FEE_TYPE_ENDPOINT),'id',32)

    {
      "api_key": @api_key,
      "claim_id": claim_uuid,
      "fee_type_id": fee_type_id,
      "quantity": 2,
      "rate": 1.55,
    }
  end

  def date_attended_data(attended_item_uuid, attended_item_type)
    {
      "api_key": @api_key,
      "attended_item_id": attended_item_uuid,
      "attended_item_type": attended_item_type,
      "date": "2015-06-01",
      "date_to": "2015-06-01"
    }
  end
end
