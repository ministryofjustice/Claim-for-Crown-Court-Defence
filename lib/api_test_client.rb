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
  ADVOCATE_PREFIX = 'api/advocates'

  # dropdown endpoints
  CASE_TYPE_ENDPOINT          = "case_types"
  COURT_ENDPOINT              = "courts"
  ADVOCATE_CATEGORY_ENDPOINT  = "advocate_categories"
  CRACKED_THIRD_ENDPOINT      = "trial_cracked_at_thirds"
  GRANTING_BODY_ENDPOINT      = "granting_body_types"
  OFFENCE_CLASS_ENDPOINT      = "offence_classes"
  OFFENCE_ENDPOINT            = "offences"
  FEE_CATEGORY_ENDPOINT       = "fee_categories"
  FEE_TYPE_ENDPOINT           = "fee_types"
  EXPENSE_TYPE_ENDPOINT       = "expense_types"

  ALL_DROPDOWN_ENDPOINTS      = [CASE_TYPE_ENDPOINT,
                                COURT_ENDPOINT,
                                ADVOCATE_CATEGORY_ENDPOINT,
                                CRACKED_THIRD_ENDPOINT,
                                GRANTING_BODY_ENDPOINT,
                                OFFENCE_CLASS_ENDPOINT,
                                OFFENCE_ENDPOINT,
                                FEE_CATEGORY_ENDPOINT,
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



  #
  # don't raise exceptions but, instead, return the
  # response for analysis.
  #
  def get_dropdown_endpoint(resource, prefix=nil)
    endpoint = RestClient::Resource.new([api_root_url, prefix || DROPDOWN_PREFIX, resource].join('/'))
    endpoint.get do |response, request, result|
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
      response = get_dropdown_endpoint(resource)
    end
  end

  def post_to_advocate_endpoint(resource, payload, prefix=nil)

    endpoint = RestClient::Resource.new([api_root_url, prefix || ADVOCATE_PREFIX, resource].join('/'))
    endpoint.post(payload, { :content_type => :json, :accept => :json } ) do |response, request, result|
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

    claim_id = JSON.parse(response)['id']

    # add a defendant
    response = post_to_advocate_endpoint('defendants', defendant_data(claim_id))

    # add representation order
    defendant_id = JSON.parse(response)['id']
    response = post_to_advocate_endpoint('representation_orders', representation_order_data(defendant_id))

    # add fee
    response = post_to_advocate_endpoint('fees', fee_data(claim_id))

    # add date attended to fee
    attended_item_id = JSON.parse(response)['id']
    response = post_to_advocate_endpoint('dates_attended', date_attended_data(attended_item_id,"fee"))

    # add expense
    response = post_to_advocate_endpoint('expenses', expense_data(claim_id))

    # add date attended to expense
    attended_item_id = JSON.parse(response)['id']
    response = post_to_advocate_endpoint('dates_attended', date_attended_data(attended_item_id,"expense"))

    #clear up/delete data
    claim = Claim.find_by(uuid: claim_id)
    if claim
      claim.destroy
    end

  end

  def claim_data

    # use endpoint dropdown/lookup data
    # NOTE: use case type 12 at index 11 (i.e. Trial) since this has least validations
    case_type_id            = json_value_at_indcex(get_dropdown_endpoint(CASE_TYPE_ENDPOINT),'id',11)
    advocate_category       = json_value_at_index(get_dropdown_endpoint(ADVOCATE_CATEGORY_ENDPOINT))
    offence_id              = json_value_at_index(get_dropdown_endpoint(OFFENCE_ENDPOINT),'id')
    court_id                = json_value_at_index(get_dropdown_endpoint(COURT_ENDPOINT),'id')
    trial_cracked_at_third  = json_value_at_index(get_dropdown_endpoint(CRACKED_THIRD_ENDPOINT))

    {
      "advocate_email": "advocate@example.com",
      "case_number": "P12345678",
      "case_type_id": case_type_id,
      "indictment_number": "12345678",
      "first_day_of_trial": "2015-06-01",
      "estimated_trial_length": 1,
      "actual_trial_length": 1,
      "trial_concluded_at": "2015-06-02",
      "advocate_category": advocate_category,
      "prosecuting_authority": "cps",
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
      "claim_id": claim_uuid,
      "first_name": "case",
      "middle_name": "management",
      "last_name": "system",
      "date_of_birth": "1979-12-10",
      "order_for_judicial_apportionment": true,
    }
  end

  def representation_order_data(defendant_uuid)

    granted_by = json_value_at_index(get_dropdown_endpoint(GRANTING_BODY_ENDPOINT))

    {
      "defendant_id": defendant_uuid,
      "granting_body": granted_by,
      "maat_reference": "45469637418",
      "representation_order_date": "2015-05-21"
    }
  end

  def expense_data(claim_uuid)

    expense_type_id = json_value_at_index(get_dropdown_endpoint(EXPENSE_TYPE_ENDPOINT),'id')

    {
      "claim_id": claim_uuid,
      "expense_type_id": expense_type_id,
      "quantity": 1,
      "rate": 1.1,
      "location": "London"
    }
  end

  def fee_data(claim_uuid)

    fee_type_id = json_value_at_index(get_dropdown_endpoint(FEE_TYPE_ENDPOINT),'id')

    {
      "claim_id": claim_uuid,
      "fee_type_id": fee_type_id,
      "quantity": 1,
      "amount": 2.1,
    }
  end

  def date_attended_data(attended_item_uuid, attended_item_type)
    {
      "attended_item_id": attended_item_uuid,
      "attended_item_type": attended_item_type,
      "date": "2015-06-01",
      "date_to": "2015-06-01"
    }
  end

end
