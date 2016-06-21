module API::V1::ExternalUsers
  module Claims
    class TransferClaim < Grape::API
      helpers API::V1::ClaimHelper

      params do
        use :common_params
        optional :user_email, type: String, desc: 'REQUIRED: The ADP account email address that uniquely identifies the litigator to whom this claim belongs.'
        optional :supplier_number, type: String, desc: 'REQUIRED. The supplier number.'
        optional :transfer_court_id, type: Integer, desc: 'REQUIRED: The unique identifier for the transfer court.'
        optional :transfer_case_number, type: String, desc: 'REQUIRED: The case number for the transfer court.'
        optional :case_concluded_at, type: String, desc: 'REQUIRED: The date the case concluded (YYYY-MM-DD)', standard_json_format: true
        # Transfer Fee Details
        optional :litigator_type, type: String, desc: 'REQUIRED: New or original.', values: %w(new original)
        optional :elected_case, type: Boolean, desc: 'REQUIRED: Was the case elected? (true or false).'
        optional :transfer_stage_id, type: Integer, desc: 'REQUIRED: When did you start acting?'
        optional :transfer_date, type: String, desc: 'REQUIRED: The date you started acting (YYYY-MM-DD)', standard_json_format: true
        optional :case_conclusion_id, type: Integer, desc: 'REQUIRED/UNREQUIRED: Only required for new litigators that transfered onto unelected cases at specific stages.'
      end

      namespace :transfer do
        desc 'Create a Litigator transfer claim.'
        post do
          create_resource(::Claim::TransferClaim)
          status api_response.status
          api_response.body
        end

        desc 'Validate a Litigator transfer claim.'
        post '/validate' do
          validate_resource(::Claim::TransferClaim)
          status api_response.status
          api_response.body
        end
      end

    end
  end
end