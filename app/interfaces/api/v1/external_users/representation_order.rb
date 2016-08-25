module API
  module V1
    module ExternalUsers

      class RepresentationOrder < Grape::API
        params do
          # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
          optional :api_key, type: String, desc: "REQUIRED: The API authentication key of the provider"
          optional :defendant_id, type: String, desc: 'REQUIRED: ID of the defendant'
          optional :maat_reference, type: String, desc: "REQUIRED: The unique identifier for this representation order"
          optional :representation_order_date, type: String, desc: "REQUIRED: The date on which this representation order was granted (YYYY-MM-DD)", standard_json_format: true
        end

        resource :representation_orders, desc: 'Create or Validate' do
          helpers do
            def defendant_id
              ::Defendant.find_by(uuid: params[:defendant_id]).try(:id) || (raise API::V1::ArgumentError, 'Defendant cannot be blank')
            end

            def build_arguments
              declared_params.merge(defendant_id: defendant_id)
            end
          end

          desc 'Create a representation_order.'
          post do
            create_resource(::RepresentationOrder)
            status api_response.status
            api_response.body
          end

          desc 'Validate a representation_order.'
          post '/validate' do
            validate_resource(::RepresentationOrder)
            status api_response.status
            api_response.body
          end
        end

      end
    end
  end
end