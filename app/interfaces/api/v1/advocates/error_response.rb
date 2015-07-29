module API
  module V1
    module Advocates

      class ErrorResponse

        attr :body
        attr :status

        def initialize(object)
          if models.include? object.class
            @model = object
            build_error_response
          elsif object.class == API::V1::ArgumentError
            @body = { error: object.message }
            @status = 400
          else
            raise "Unable to generate an error response for the class #{object.class}"
          end
        end

        def models
          [::Fee, ::Expense, ::Claim, ::Defendant, ::DateAttended]
        end

        def build_error_response
          if !@model.errors.empty?

            error_messages = []

            @model.errors.full_messages.each do |error_message|
              error_messages.push({ error: error_message })
            end

            @body = error_messages
            @status = 400

          else
             raise "unable to build error response as no errors were found"
           end
        end
      end
    end
  end
end
