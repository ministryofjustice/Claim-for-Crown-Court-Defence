module TimedTransitions
  class Specification
    attr_reader :current_state, :number_of_days, :method

    def initialize(current_state, number_of_days, method)
      @current_state  = current_state
      @number_of_days = number_of_days
      @method         = method
    end
  end
end