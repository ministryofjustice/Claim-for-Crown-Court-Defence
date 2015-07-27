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
              requires :rate, type: Integer
            end

            def args
              {
                claim_id: params[:claim_id],
                fee_type_id: params[:fee_type_id],
                quantity: params[:quantity],
                rate: params[:rate]
              }
            end

            def fee_args_valid?
              begin
                fee = ::Fee.new(args)
                if fee.valid?
                  true
                else
                  # contruct array of error message hashes from model
                  error_messages = []
                  fee.errors.full_messages.each do |error_message|
                    error_messages.push({ error: error_message })
                  end
                  { status: 400, body: error_messages }
                end
              rescue API::V1::ArgumentError => ae
                return { status: 400, body: { error: ae.message } }
              end
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
            arg_response = fee_args_valid?
            if arg_response == true
              status 200
              arg_response
            else
              status arg_response[:status]
              arg_response[:body]
            end
          end

        end


      end

    end

  end
end
