module API
  module V1

    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates


      class Claim < Grape::API

        version 'v1', using: :header, vendor: 'Advocate Defence Payments'
        format :json
        prefix 'api/advocates'
        content_type :json, 'application/json'

        resource :claims, desc: 'Create or Validate' do

          helpers do
            params :claim_parameters do
              requires :advocate_email, type: String, desc: "Your ADP account email address that uniquely identifies you."
              requires :case_number, type: String, desc: "The case number"
              requires :case_type_id, type: Integer, desc: "The unique identifier of the case type"
              requires :indictment_number, type: String, desc: "The indictment number"
              requires :first_day_of_trial, type: Date, desc: "YYYY/MM/DD"
              requires :estimated_trial_length, type: Integer, desc: "The estimated trial length in days"
              requires :actual_trial_length, type: Integer, desc: "The actual trial length in days"
              requires :trial_concluded_at, type: Date, desc: "The the trial concluded"
              requires :advocate_category, type: String, values: Settings.advocate_categories, desc: "The category of the advocate"
              requires :offence_id, type: Integer, desc: "The unique identifier for this offence"
              requires :court_id, type: Integer, desc: "The unique identifier for this court"

              optional :cms_number, type: String, desc: "The CMS number"
              optional :additional_information , type: String, desc: "Any additional information"
              optional :apply_vat , type: Boolean, desc: "Include VAT (True or False)"
              optional :trial_fixed_notice_at, type: Date, desc: "YYYY/MM/DD"
              optional :trial_fixed_at, type: Date, desc: "YYYY/MM/DD"
              optional :trial_cracked_at, type: Date, desc: "YYYY/MM/DD"
              optional :trial_cracked_at_third, type: String, values: Settings.trial_cracked_at_third, desc: "The third in which this case was cracked."
            end

            def build_arguments
              user = User.advocates.find_by(email: params[:advocate_email])
              if user.blank?
                raise API::V1::ArgumentError, 'advocate_email is invalid'
              else
                {
                  advocate_id:              user.persona_id,
                  creator_id:               user.persona_id,
                  source:                   'api',
                  case_number:              params[:case_number],
                  case_type_id:             params[:case_type_id],
                  indictment_number:        params[:indictment_number],
                  first_day_of_trial:       params[:first_day_of_trial],
                  estimated_trial_length:   params[:estimated_trial_length],
                  actual_trial_length:      params[:actual_trial_length],
                  trial_concluded_at:       params[:trial_concluded_at],
                  advocate_category:        params[:advocate_category],
                  cms_number:               params[:cms_number],
                  additional_information:   params[:additional_information],
                  apply_vat:                params[:apply_vat],
                  trial_fixed_notice_at:    params[:trial_fixed_notice_at],
                  trial_fixed_at:           params[:trial_fixed_at],
                  trial_cracked_at:         params[:trial_cracked_at],
                  trial_cracked_at_third:   params[:trial_cracked_at_third],
                  offence_id:               params[:offence_id],
                  court_id:                 params[:court_id],
                }
              end
            end
          end

          desc "Create a claim."

          params do
            use :claim_parameters
          end

          post do
            begin
              arguments = build_arguments
            rescue => error
              arguments_error = ErrorResponse.new(error)
              status arguments_error.status
              return arguments_error.body
            end

            claim = ::Claim.create(arguments)

            if !claim.errors.empty?
              error = ErrorResponse.new(claim)
              status error.status
              return error.body
            end

            status 201

            api_response = { 'id' => claim.reload.uuid }.merge!(declared(params))

            api_response
          end

          desc "Validate a claim."

          params do
            use :claim_parameters
          end

          post '/validate' do
            begin
                arguments = build_arguments
            rescue => error
              arguments_error = ErrorResponse.new(error)
              status arguments_error.status
              return arguments_error.body
            end

            claim = ::Claim.new(arguments)

            if !claim.valid?
              error = ErrorResponse.new(claim)
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
