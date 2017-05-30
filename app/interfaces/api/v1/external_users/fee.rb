module API
  module V1
    module ExternalUsers
      class Fee < Grape::API
        params do
          # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
          optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the provider'
          optional :claim_id, type: String, desc: 'REQUIRED: The unique identifier for the corresponding claim.'
          optional :fee_type_id, type: Integer, desc: 'OPTIONAL: The unique numeric ID for the corresponding fee type if fee_type_unique_code is not specified.'
          optional :fee_type_unique_code, type: String, desc: 'OPTIONAL: The unique alphanumeric CODE for the corresponding fee type if fee_type_id is not specified'
          mutually_exclusive :fee_type_id, :fee_type_unique_code
          optional :quantity, type: Float, desc: 'REQUIRED/UNREQUIRED: The number of fees of this fee type that are being claimed (quantity x rate will equal amount). NB: Leave blank if not applicable'
          optional :rate, type: Float, desc: 'REQUIRED/UNREQUIRED: The currency value per unit/quantity of the fee (quantity x rate will equal amount). NB: Leave blank for PPE and NPW fee types'
          optional :amount, type: Float, desc: 'REQUIRED/UNREQUIRED: The total value of the fee. NB: Leave blank for fee types other than PPE/NPW or a Transfer Fee'
          optional :case_numbers, type: String, desc: 'REQUIRED/UNREQUIRED: Required for Miscellaneous Fee of type Case Uplift. Leave blank for other types'
          optional :date, type: String, desc: 'REQUIRED/UNREQUIRED: Required for LGFS Fixed Fee or LGFS Graduated Fee, otherwise leave blank (YYYY-MM-DD)', standard_json_format: true
          optional :warrant_issued_date, type: String, desc: 'REQUIRED/UNREQUIRED: Required for Interim fee of type Warrant, or a Warrant Fee, otherwise leave blank (YYYY-MM-DD)', standard_json_format: true
          optional :warrant_executed_date, type: String, desc: 'OPTIONAL: For Interim fee of type Warrant, or a Warrant Fee, otherwise leave blank (YYYY-MM-DD)', standard_json_format: true
        end

        resource :fees, desc: 'Create or Validate' do
          helpers do
            def build_arguments
              declared_params.merge(claim_id: claim_id)
            end
          end

          desc 'Create a fee.'
          post do
            create_resource(::Fee::BaseFee)
            status api_response.status
            api_response.body
          end

          desc 'Validate a fee.'
          post '/validate' do
            validate_resource(::Fee::BaseFee)
            status api_response.status
            api_response.body
          end
        end
      end
    end
  end
end
