module API
  module V1

    
    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates

      class Fee < Grape::API

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :fees do

          helpers do
            params :fee_creation do
              requires :claim_id, type: Integer
              requires :fee_type_id, type: Integer
              requires :quantity, type: Integer
              requires :amount, type: Float
            end

            def args
              {
                claim_id: params[:claim_id],
                fee_type_id: params[:fee_type_id],
                quantity: params[:quantity],
              }
            end

          end

          desc "Create a fee."

          params do
            use :fee_creation
          end

          post do
            ::Fee.create!(args)
          end


          desc "Validate a fee."

          params do
            use :fee_creation
          end

          post '/validate' do
            fee = ::Fee.new(args)

            if !fee.valid?
                    error = ErrorResponse.new(fee)
              status error.status
              return error.body
            end

            status 200
            { valid: true }
          end

        end


      end

    end

  end
end