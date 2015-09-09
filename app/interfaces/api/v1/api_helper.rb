module API
  module V1

    module ApiHelper
      require './app/interfaces/api/custom_validations/date_format.rb'
      # --------------------
      class ApiResponse
        attr_accessor :status, :body

        def success?(status_code=nil)
          code = status_code ||= '2'
          status.to_s =~ /^#{code}/ ? true : false
        end
      end

      # --------------------
      class ErrorResponse

        attr :body
        attr :status

        VALID_MODELS = [Fee, Expense, Claim, Defendant, DateAttended, RepresentationOrder]

        def initialize(object)
          @error_messages = []

          if VALID_MODELS.include? object.class
            @model = object
            build_error_response
          else
            # temp workaround til rails 4.2 upgrade which should fix malformed UUID error and raise ActiveRecord::RecordNotFound
            if object.inspect.include? 'PG::InvalidTextRepresentation: ERROR:  invalid input syntax for uuid:'
              @body = error_messages.push({ error: "malformed UUID" })
            else
              @body = error_messages.push({ error: object.message })
            end
            @status = 400
          end

        end

      private

        def error_messages
          @error_messages
        end

        def build_error_response
          unless @model.errors.empty?

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

      # --------------------
      def self.create_resource(model_object, params, api_response, arg_builder_proc)

        model_instance = validate_resource(model_object, api_response, arg_builder_proc)

        if api_response.success?(200)
          model_instance.save!
          api_response.status = 201
          api_response.body =  { 'id' => model_instance.reload.uuid }.merge!(params)
        end

        model_instance

      # unexpected errors could be raised at point of save as well
      rescue Exception => ex
        err_resp = ErrorResponse.new(ex)
        api_response.status = err_resp.status
        api_response.body   = err_resp.body
      end

       # --------------------
      def self.validate_resource(model_object, api_response, arg_builder_proc)
        model_instance = model_object.new(arg_builder_proc.call)

        if model_instance.valid?
          api_response.status = 200
          api_response.body =  { valid: true }
        else
          err_resp = ErrorResponse.new(model_instance)
          api_response.status = err_resp.status
          api_response.body   = err_resp.body
        end

        model_instance

      rescue Exception => ex
        err_resp = ErrorResponse.new(ex)
        api_response.status = err_resp.status
        api_response.body   = err_resp.body
      end

    end
  end
end
