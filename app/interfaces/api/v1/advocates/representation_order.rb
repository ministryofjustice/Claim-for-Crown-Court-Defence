module API
  module V1

    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates

      class RepresentationOrder < Grape::API

        include ApiHelper

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :representation_orders, desc: 'Create or Validate' do

          helpers do
            params :representation_order_creation do
              # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
              optional :defendant_id, type: String,             desc: 'REQUIRED: ID of the defendant'
              optional :granting_body, type: String,            desc: "REQUIRED: The court which granted this representation order (Crown Court or Magistrate's Court)"
              optional :maat_reference, type: String,           desc: "REQUIRED: The unique identifier for this representation order"
              optional :representation_order_date, type: Date,  desc: "REQUIRED: The date on which this representation order was granted (YYYY/MM/DD)"
            end

            def build_arguments
              defendant_id = ::Defendant.find_by(uuid: params[:defendant_id]).try(:id)

               # TODO review in code review
               # NOTE: explicit error raising because defendant_id's presence is not validated by model due to instatiation issues
              if defendant_id.nil?
                raise API::V1::ArgumentError, 'Defendant can\'t be blank'
              end

              {
                defendant_id: defendant_id,
                granting_body: params[:granting_body],
                maat_reference: params[:maat_reference],
                representation_order_date: params[:representation_order_date]
              }
            end

          end

          desc "Create a representation_order."

          params do
            use :representation_order_creation
          end

          post do
            api_response = ApiResponse.new()
            ApiHelper.create_resource(::RepresentationOrder, params, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end


          desc "Validate a representation_order."

          params do
            use :representation_order_creation
          end

          post '/validate' do
            api_response = ApiResponse.new()
            ApiHelper.validate_resource(::RepresentationOrder, api_response, method(:build_arguments).to_proc)
            status api_response.status
            return api_response.body
          end
        end
      end
    end
  end
end
