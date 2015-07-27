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
            if fee.valid?
              status 200
              true
            else
              status 400
              false
            end
          end

        end


      end

    end

  end
end
