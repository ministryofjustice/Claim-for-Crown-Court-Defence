module Claims
  class CaseWorkerClaimUpdater
    include CaseWorkerClaimParamReadable
    attr_reader :claim, :params, :result, :messages, :validator

    def initialize(claim_id, params)
      @params = params
      @claim = Claim::BaseClaim.active.find(claim_id)
      @validator = ClaimStateTransitionValidator.new(claim, params.dup)
      @messages = @claim.messages.most_recent_last
    end

    def update!
      @result = validator.call
      update_and_transition_state if result.eql?(:ok)
      self
    end

    private

    def update_and_transition_state
      event = Claims::InputEventMapper.input_event(state)

      claim.class.transaction do
        update_assessment if assessment_params
        add_redetermination if redetermination_params
        claim.send(event, audit_attributes) unless state_not_updateable?
        add_message if transition_reasons.present?
      rescue StandardError => err
        @result = validator.add_error(err.message)
        raise ActiveRecord::Rollback
      end
    end

    def state_not_updateable?
      state.blank? || state.eql?(claim.state)
    end

    def update_assessment
      claim.assessment.update(assessment_params)
    end

    def add_redetermination
      claim.redeterminations.create(redetermination_params)
    end

    def add_message
      return unless Release.reject_refuse_messaging_released?
      claim.messages.create(sender_id: current_user.id, body: transition_message)
    end

    def transition_message
      StateTransitionMessageBuilder.new(state, transition_reasons, transition_reason_text).call
    end

    def audit_attributes
      {
        author_id: current_user&.id,
        reason_code: transition_reasons,
        reason_text: transition_reason_text
      }
    end
  end
end
