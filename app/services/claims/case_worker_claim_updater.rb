module Claims
  class CaseWorkerClaimUpdater
    attr_reader :claim, :result, :messages

    def initialize(claim_id, params)
      @params = params
      @claim = Claim::BaseClaim.find(claim_id)
      @messages = @claim.messages.most_recent_last
      @state = @params.delete('state_for_form')
      extract_assessment_params
      extract_redetermination_params
      @result = :ok
    end

    def update!
      validate_params
      update_and_transition_state if @result == :ok
      self
    end

    private

    def extract_assessment_params
      @assessment_params = @params.delete('assessment_attributes')
      @assessment_params_present = nil_or_empty?(@assessment_params) ? false : true
    end

    def extract_redetermination_params
      @redetermination_params = @params.delete('redeterminations_attributes')
      @redetermination_params = @redetermination_params['0'] unless @redetermination_params.nil?
      @redetermination_params_present = nil_or_empty?(@redetermination_params) ? false : true
    end

    def validate_params
      if @assessment_params_present || @redetermination_params_present
        validate_state_when_value_params_present
      else
        validate_state_when_no_value_params
      end
    end

    def validate_state_when_value_params_present
      if @state.blank?
        @claim.errors[:determinations] << 'You must specify authorised or part authorised if you supply values'
        @result = :error
      elsif @state == 'refused'
        @claim.errors[:determinations] << 'You cannot specify values when refusing a claim'
        @result = :error
      elsif @state == 'rejected'
        @claim.errors[:determinations] << 'You cannot specify values when rejecting a claim'
        @result = :error
      end
    end

    def validate_state_when_no_value_params
      if @state.in?(%w{ authorised part_authorised })
        @claim.errors[:determinations] << 'You must specify values if authorising or part authorising a claim'
        @result = :error
      end
    end

    def nil_or_empty?(determination_params)
      return true if determination_params.nil?
      result = true
      %w{ fees expenses disbursements }.each do |field|
        next if determination_params[field].to_f == 0.0
        result = false
        break
      end
      result
    end

    def update_and_transition_state
      @claim.update(@params)
      event = Claims::InputEventMapper.input_event(@state)
      update_assessment if @assessment_params_present
      add_redetermination if @redetermination_params_present
      @claim.send(event) unless (@state.blank? || @state == @claim.state)
    end

    def update_assessment
      params_with_defaults = {'fees' => '0.00', 'expenses' => '0.00', 'disbursements' => '0.00'}.merge(@assessment_params)
      @claim.assessment.update(params_with_defaults)
    end

    def add_redetermination
      params_with_defaults = {'fees' => '0.00', 'expenses' => '0.00', 'disbursements' => '0.00'}.merge(@redetermination_params)
      @claim.redeterminations << Redetermination.new(params_with_defaults)
    end
  end
end
