module TimedTransitions

  class Specification

    attr_reader :current_state, :period_in_weeks, :method

    def initialize(current_state, period_in_weeks, method)
      @current_state    = current_state
      @period_in_weeks  = period_in_weeks
      @method           = method
    end

  end
end