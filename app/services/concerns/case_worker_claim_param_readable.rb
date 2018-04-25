module CaseWorkerClaimParamReadable
  extend ActiveSupport::Concern

  included do
    def current_user
      @current_user ||= params[:current_user]
    end

    def state
      @state ||= params['state']
    end

    def transition_reasons
      @transition_reasons ||= params['state_reason']&.reject(&:empty?)
    end

    def transition_reason_text
      @transition_reason_text ||= reason_text
    end

    def reason_text
      reasons = {
        rejected: params['reject_reason_text'],
        refused: params['refuse_reason_text']
      }
      reasons[state.to_sym] if state.present?
    end

    def assessment_params
      @assessment_params ||= assessment_attributes
    end

    def assessment_attributes
      determination_with_defaults(params['assessment_attributes']) if determination_non_zero?(params['assessment_attributes'])
    end

    def redetermination_params
      @redetermination_params ||= redeterminations_attributes
    end

    def redeterminations_attributes
      redetermination_params = params.dig('redeterminations_attributes', '0')
      determination_with_defaults(redetermination_params) if determination_non_zero?(redetermination_params)
    end

    def state_verb
      @state_verb ||= state.eql?('refused') ? 'refusing' : 'rejecting'
    end

    def state_symbol(other_suffix = true)
      @state_noun ||= "#{state}_reason#{'_other' if other_suffix}".to_sym
    end

    def transition_reason_text_missing?
      transition_reasons&.any? { |reason| %w[other other_refuse].include?(reason) } &&
        transition_reason_text.blank?
    end

    def determination_with_defaults(attributes)
      attributes.reject! { |_k, v| v.blank? }
      {
        'fees' => '0.00',
        'expenses' => '0.00',
        'disbursements' => '0.00'
      }.merge(attributes)
    end

    def determination_non_zero?(params)
      return false unless params.present?
      %w[fees expenses disbursements].any? { |field| params[field].to_f > 0.0 }
    end

    def determination_present?
      assessment_params || redetermination_params
    end

    def reasons_present?
      transition_reasons.present? || transition_reason_text.present?
    end

    def add_error(message, attribute = :determinations)
      claim.errors[attribute] << message
      @result = :error
    end
  end
end
