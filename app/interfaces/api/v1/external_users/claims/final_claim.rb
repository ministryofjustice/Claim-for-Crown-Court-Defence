module API::V1::ExternalUsers
  module Claims
    class FinalClaim < Grape::API
      helpers API::V1::ClaimHelper

      params do
        use :common_params
        optional :user_email, type: String, desc: 'REQUIRED: The ADP account email address that uniquely identifies the litigator to whom this claim belongs.'
        optional :supplier_number, type: String, desc: 'REQUIRED. The supplier number.'
        optional :transfer_court_id, type: Integer, desc: 'REQUIRED: The unique identifier for the transfer court.'
        optional :transfer_case_number, type: String, desc: 'REQUIRED: The case number for the transfer court.'
        optional :case_concluded_at, type: String, desc: 'REQUIRED: The date the case concluded (YYYY-MM-DD)', standard_json_format: true
        optional :actual_trial_length, type: Integer, desc: 'REQUIRED/UNREQUIRED: The actual trial length in days, required for graduated fees.'
      end

      namespace :final do
        desc 'Create a Litigator final claim.'
        post do
          create_resource(::Claim::LitigatorClaim)
          status api_response.status
          api_response.body
        end

        desc 'Validate a Litigator final claim.'
        post '/validate' do
          validate_resource(::Claim::LitigatorClaim)
          status api_response.status
          api_response.body
        end
      end

    end
  end
end