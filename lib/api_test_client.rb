require 'rest-client'
require 'net/http'

class ApiTestClient

  DROPDOWN_PREFIX = 'api'
  ADVOCATE_PREFIX = 'api/advocates'
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

  ALL_DROPDOWN_ENDPOINTS       = [CASE_TYPE_ENDPOINT,
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
    @messages = []
    @success = true
    run
  end

  def success
    @success
  end

  def errors
    @errors
  end

  def messages
    @messages
  end

private

  def run
    test_dropdown_endpoints
    test_claim_creation
  end

  def api_root_url
    GrapeSwaggerRails.options.app_url
  end

  #
  # don't raise exceptions (this is a intended for a scheduled rake task for
  # which we do NOT want to raise harmful exceptions) but, instead, return the
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
      end
      response
    end
  end

  #
  # just check for successful return of all lookup/dropdown data from
  # all relevant endpoints
  #
  def test_dropdown_endpoints
    ALL_DROPDOWN_ENDPOINTS.each do |resource|
      response = get_dropdown_endpoint(resource)
    end
  end

  def post_to_advocate_endpoint(resource, payload, prefix=nil)

    endpoint = RestClient::Resource.new([api_root_url, prefix || ADVOCATE_PREFIX, resource].join('/'))

    endpoint.post(payload, { :content_type => :json, :accept => :json }) do |response, request, result|
      if response.code.to_s =~ /^2/
        @messages << "#{resource} Endpoint returned success code - #{response.code}"
      else
        @success = false
        @errors << "#{resource} Endpoint raised error - #{response.code}"
      end
      response
    end

  end

  def test_claim_creation_endpoints

    # create a claim
    response = post_to_advocate_endpoint('claims', valid_claim_data)

    # add a defendant

    # add representation order

    # add fee

    # add date attended to fee

    # add expense

    # add date attended to expense

    #
  end

  def valid_claim_data
    {
      "advocate_email": "advocate@example.com",
      "case_number": "12345678",
      "case_type_id": 1,
      "indictment_number": "12345678",
      "first_day_of_trial": "2015/06/01",
      "estimated_trial_length": 1,
      "actual_trial_length": 1,
      "trial_concluded_at": "2015/06/02",
      "advocate_category": "QC",
      "prosecuting_authority": "cps",
      "offence_id": 1,
      "court_id": 1,
      "cms_number": "12345678",
      "additional_information": "string",
      "apply_vat": true,
      "trial_fixed_notice_at": "2015-06-01",
      "trial_fixed_at": "2015-06-01",
      "trial_cracked_at": "2015-06-01"
      }
  end

  def valid_defendant_data
    {
      "first_name": "case",
      "middle_name": "management",
      "last_name": "system",
      "date_of_birth": "1979/12/10",
      "order_for_judicial_apportionment": true,
      "representation_orders": [
        {
          "granting_body": "Crown Court",
          "maat_reference": "12345678",
          "representation_order_date": "2015/05/01"
        }
      ]
    }
  end

  def valid_expense_data
      {
        "expense_type_id": 1,
        "quantity": 1,
        "rate": 1.1,
        "location": "London",
        "dates_attended": [
          {
            "attended_item_type": "expense",
            "date": "2015/06/01",
            "date_to": "2015/06/01"
          }
        ]
      }
  end

  def valid_fee_data
      {
        "fee_type_id": 75,
        "quantity": 1,
        "amount": 1.1,
        "dates_attended": [
          {
            "attended_item_type": "fee",
            "date": "2015/06/01",
            "date_to": "2015/06/01"
          }
        ]
      }
  end

end