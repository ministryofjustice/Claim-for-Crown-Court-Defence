module ApiHelper

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

    def initialize(object)
      @error_messages = []

      if models.include? object.class
        @model = object
        build_error_response
      else
        @body = error_messages.push({ error: object.message })
        @status = 400
      end

    end

    def error_messages
      @error_messages
    end

    def models
      [::Fee, ::Expense, ::Claim, ::Defendant, ::DateAttended, ::RepresentationOrder]
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


  def self.claim_arguments(params)
    user = User.advocates.find_by(email: params[:advocate_email])
    if user.blank?
      raise API::V1::ArgumentError, 'Advocate email is invalid'
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

  # --------------------
  def self.create_claim(params, api_response)
    claim = validate_claim(params,api_response)
    if api_response.success?(200)
      claim.save
      api_response.status = 201
      api_response.body =  { 'id' => claim.reload.uuid }.merge!(params)
    end
    claim
  end

  # --------------------
  def self.validate_claim(params, api_response)
    begin
      args = claim_arguments(params)
      claim = Claim.new(args)
      if claim.valid?
        api_response.status = 200
        api_response.body =  { valid: true }
      else
        err_resp = ErrorResponse.new(claim)
        api_response.status = err_resp.status
        api_response.body   = err_resp.body
      end
      claim
    rescue Exception => ex
      err_resp = ErrorResponse.new(ex)
      api_response.status = err_resp.status
      api_response.body   = err_resp.body
    end
  end



  # --------------------
  def self.create_model_instance(model_instance, params, api_response)
    # claim = validate_claim(params,api_response)
    model_instance = validate_model_object(model_instance.__send__('class'), params, api_response)

    if api_response.success?(200)
      # claim.save
      model_instance.__send__('save')
      api_response.status = 201
      # api_response.body =  { 'id' => claim.reload.uuid }.merge!(params)
      api_response.body =  { 'id' => model_instance.__send__('reload').__send__('uuid') }.merge!(params)
    end

    # claim
    model_instance
  end

   # --------------------
  def self.validate_model_object(model_object, params, api_response, proc=nil)
    begin
      # args = claim_arguments(params)
      args = proc.call(params) if proc

      # claim = Claim.new(args)
      model_instance = model_object.__send__('new',args)

      if model_object.__send__('valid?')
        api_response.status = 200
        api_response.body =  { valid: true }
      else
        err_resp = ErrorResponse.new(model_instance)
        api_response.status = err_resp.status
        api_response.body   = err_resp.body
      end
      claim
    rescue Exception => ex
      err_resp = ErrorResponse.new(ex)
      api_response.status = err_resp.status
      api_response.body   = err_resp.body
    end
  end

end