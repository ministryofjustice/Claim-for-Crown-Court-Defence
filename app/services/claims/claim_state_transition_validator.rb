module Claims
  class ClaimStateTransitionValidator
    include CaseWorkerClaimParamReadable
    attr_accessor :claim, :params, :result

    def initialize(claim, params)
      @claim = claim
      @params = params
      @result = :ok
    end

    def call
      validate
    end

    def add_error(message, attribute = :determinations)
      claim.errors[attribute] << message
      @result = :error
    end

    private

    def validate
      add_error('You must select a status') if state.blank?
      send("validate_#{state}") if state&.in?(%w[authorised part_authorised refused rejected])
      result
    end

    def validate_authorised
      common_determination_validations
    end

    def validate_part_authorised
      common_determination_validations
    end

    def validate_refused
      common_undetermined_validations
    end

    def validate_rejected
      common_undetermined_validations
    end

    def common_determination_validations
      add_error('You must provide values when [part] authorising') unless determination_present?
      add_error('You cannot provide reject/refuse reasons with an assessment') if reasons_present?
    end

    def common_undetermined_validations
      add_error("You cannot specify values when #{state_verb} a claim") if determination_present?
      add_error("requires a reason when #{state_verb}", state_symbol(false)) if transition_reasons&.empty?
      add_error('needs a description', state_symbol) if transition_reason_text_missing?
    end
  end
end
