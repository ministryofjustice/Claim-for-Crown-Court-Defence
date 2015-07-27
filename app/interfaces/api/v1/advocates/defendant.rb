module API
  module V1

    
    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates

      class Defendant < Grape::API

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :defendants do

          helpers do
            params :defendant_creation do
              requires :claim_id, type: Integer, desc: "Unique identifier for the claim associated with this defendant."
              requires :first_name, type: String, not_blank: :true, desc: "First name of the defedant."
              optional :middle_name, type: String, desc: "Middle name of the defendant."
              requires :last_name, type: String, not_blank: :true, desc: "Last name of the defendant."
              requires :date_of_birth, type: DateTime, not_blank: :true, desc: "Defendant's date of birth."
              optional :order_for_judicial_apportionment, type: Boolean
            end

            class NotBlank < Grape::Validations::Base
             def validate_param!(attr_name, params)
                if params[attr_name.to_sym].blank?
                  fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "cannot be blank"
                end
              end
            end

            def args
              {
                claim_id: params[:claim_id],
                first_name: params[:first_name],
                middle_name: params[:middle_name],
                last_name: params[:last_name],
                date_of_birth: params[:date_of_birth],
                order_for_judicial_apportionment: params[:order_for_judicial_apportionment]
              }
            end

          end

          desc "Create a defendant."

          params do
            use :defendant_creation
          end

          post do
            ::Defendant.create!(args)
          end

        end


      end

    end

  end
end