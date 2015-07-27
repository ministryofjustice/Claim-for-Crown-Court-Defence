module API
  module V1
    module Advocates

      class ErrorResponse

        attr :body
        attr :status

        def initialize(object)
          case object
          when ::Claim
            @claim = object
            build_claim_error_response
          when API::V1::ArgumentError
            @body = { error: object.message }
            @status = 400
          else
            raise "Unable to generate an error response for the class #{object.class}"
          end
        end

        def build_claim_error_response
          if !@claim.errors.empty?

            error_messages = []

            @claim.errors.full_messages.each do |error_message|
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
