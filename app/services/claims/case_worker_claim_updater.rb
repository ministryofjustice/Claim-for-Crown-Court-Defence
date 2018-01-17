module Claims
  class CaseWorkerClaimUpdater
    attr_reader :current_user, :claim, :result, :messages

    def initialize(claim_id, params)
      @params = params
      @claim = Claim::BaseClaim.active.find(claim_id)
      @messages = @claim.messages.most_recent_last
      extract_transition_params
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

    def extract_transition_params
      @state = @params.delete('state')
      @transition_reason = @params.delete('state_reason')&.reject(&:empty?)
      @transition_reason_text = extract_reason_text
      @current_user = @params.delete(:current_user)
    end

    def extract_reason_text
      reasons = {
        rejected: @params.delete('reject_reason_text'),
        refused: @params.delete('refuse_reason_text')
      }
      reasons[@state.to_sym]
    end

    def extract_assessment_params
      @assessment_params = @params.delete('assessment_attributes')
      @assessment_params_present = nil_or_empty_zero_or_negative?(@assessment_params) ? false : true
    end

    def extract_redetermination_params
      @redetermination_params = @params.delete('redeterminations_attributes')
      @redetermination_params = @redetermination_params['0'] unless @redetermination_params.nil?
      @redetermination_params_present = nil_or_empty_zero_or_negative?(@redetermination_params) ? false : true
    end

    def validate_params
      if @assessment_params_present || @redetermination_params_present
        validate_state_when_value_params_present
      elsif @state.blank?
        add_error 'You should select a status'
      else
        validate_state_when_no_value_params
        validate_reason_presence
      end
    end

    def validate_state_when_value_params_present
      if @state.blank?
        add_error 'You must specify authorised or part authorised if you supply values'
      elsif @state == 'refused'
        add_error 'You cannot specify values when refusing a claim'
      elsif @state == 'rejected'
        add_error 'You cannot specify values when rejecting a claim'
      end
    end

    def validate_state_when_no_value_params
      return unless @state.in?(%w[authorised part_authorised])
      add_error 'You must specify positive values if authorising or part authorising a claim'
    end

    def validate_reason_presence
      return unless %w[rejected refused].include?(@state)
      add_error("requires a reason when #{state_verb}", state_symbol(false)) if @transition_reason&.empty?
      add_error('needs a description', state_symbol) if transition_reason_text_missing?
    end

    def state_verb
      @state_verb ||= @state.eql?('refused') ? 'refusing' : 'rejecting'
    end

    def state_symbol(other_suffix = true)
      @state_noun ||= "#{@state}_reason#{'_other' if other_suffix}".to_sym
    end

    def transition_reason_text_missing?
      @transition_reason&.any? { |reason| %w[other other_refuse].include?(reason) } && @transition_reason_text.blank?
    end

    def nil_or_empty_zero_or_negative?(determination_params)
      return true if determination_params.nil?
      result = true
      %w[fees expenses disbursements].each do |field|
        next if determination_params[field].to_f <= 0.0
        result = false
        break
      end
      result
    end

    def update_and_transition_state
      event = Claims::InputEventMapper.input_event(@state)

      @claim.class.transaction do
        begin
          @claim.update(@params)
          update_assessment if @assessment_params_present
          add_redetermination if @redetermination_params_present
          @claim.send(event, audit_attributes) unless state_not_updateable?
        rescue StandardError => err
          add_error err.message
          raise ActiveRecord::Rollback
        end
      end
    end

    def state_not_updateable?
      @state.blank? || @state == @claim.state
    end

    def update_assessment
      params_with_defaults = {
        'fees' => '0.00',
        'expenses' => '0.00',
        'disbursements' => '0.00'
      }.merge(@assessment_params)
      @claim.assessment.update(params_with_defaults)
    end

    def add_redetermination
      params_with_defaults = {
        'fees' => '0.00',
        'expenses' => '0.00',
        'disbursements' => '0.00'
      }.merge(@redetermination_params)
      @claim.redeterminations << Redetermination.new(params_with_defaults)
    end

    def add_error(message, attribute = :determinations)
      @claim.errors[attribute] << message
      @result = :error
    end

    def audit_attributes
      {
        author_id: current_user&.id,
        reason_code: @transition_reason,
        reason_text: @transition_reason_text
      }
    end
  end
end
