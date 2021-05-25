module TimedTransitions
  class Specification
    attr_reader :period_in_weeks, :method

    def initialize(period_in_weeks, method)
      @period_in_weeks  = period_in_weeks
      @method           = method
    end
  end
end
