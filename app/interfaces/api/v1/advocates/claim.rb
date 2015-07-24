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

        resource :claims do

          helpers do
            params :claim_parameters do
              requires :advocate_email, type: String, desc: "Your ADP account email address that uniquely identifies you."
              requires :case_number, type: String, desc: "The case number"
              requires :case_type, type: String, desc: "The case type i.e trial"
              requires :indictment_number, type: String, desc: "The indictment number"
              requires :first_day_of_trial, type: Date, desc: "The first day of the trial"
              requires :estimated_trial_length, type: Integer, desc: "The estimated trial length in days"
              requires :actual_trial_length, type: Integer, desc: "The actual trial length in days"
              requires :trial_concluded_at, type: Date, desc: "The the trial concluded"
              requires :advocate_category, type: String, desc: "The category of the advocate"

              optional :cms_number, type: String, desc: "The CMS number"
              optional :additional_information , type: String, desc: "Any additional information"
              optional :apply_vat , type: Boolean, desc: "Include VAT (True or False)"
              optional :prosecuting_authority, type: String, desc: "The prosecuting authority"
              optional :trial_fixed_notice_at, type: Date, desc: "The trial fixed notice date"
              optional :trial_fixed_at, type: Date, desc: "The trial fixed date"
              optional :trial_cracked_at, type: Date, desc: "The trial cracked date"
              optional :trial_cracked_at_third, type: Date, desc: "The trial cracked (third) date"
            end

            def build_arguements
              user = User.advocates.find_by(email: params[:advocate_email])
              if user.blank?
                raise API::V1::ArgumentError, 'advocate_email is invalid'
              else
                {
                  advocate_id:              user.persona_id,
                  creator_id:               user.persona_id,
                  source:                   'api',
                  case_number:              params[:case_number],
                  case_type:                params[:case_type],
                  indictment_number:        params[:indictment_number],
                  first_day_of_trial:       params[:first_day_of_trial],
                  estimated_trial_length:   params[:estimated_trial_length],
                  actual_trial_length:      params[:actual_trial_length],
                  trial_concluded_at:       params[:trial_concluded_at],
                  advocate_category:        params[:advocate_category],
                  cms_number:               params[:cms_number],
                  additional_information:   params[:additional_information],
                  apply_vat:                params[:apply_vat],
                  prosecuting_authority:    params[:prosecuting_authority],
                  trial_fixed_notice_at:    params[:trial_fixed_notice_at],
                  trial_fixed_at:           params[:trial_fixed_at],
                  trial_cracked_at:         params[:trial_cracked_at],
                  trial_cracked_at_third:   params[:trial_cracked_at_third],
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
  	      arguements = build_arguements
	    rescue => error
	      arguements_error = ErrorResponse.new(error)
	      status arguements_error.status
	      return arguements_error.body
	    end

            claim = ::Claim.create(arguements)

	    if !claim.errors.empty?
              error = ErrorResponse.new(claim)
	      status error.status
	      return error.body
	    end

            status 201
            api_response = { 'id' => claim.id }.merge!(declared(params))

            api_response
          end

          desc "Validate a claim."

          params do
            use :claim_parameters
          end

          post '/validate' do
	    begin
  	      arguements = build_arguements
	    rescue => error
	      arguements_error = ErrorResponse.new(error)
	      status arguements_error.status
	      return arguements_error.body
	    end

            claim = ::Claim.new(arguements)

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
