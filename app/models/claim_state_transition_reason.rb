class ClaimStateTransitionReason
  class ReasonNotFoundError < StandardError; end
  class StateNotFoundError < StandardError; end

  attr_accessor :code, :description

  TRANSITION_REASONS = HashWithIndifferentAccess.new(
    rejected: {
      no_indictment: 'No indictment attached',
      no_rep_order: 'No rep order attached (granted before 1/8/2015)',
      time_elapsed: 'More than 3 months has elapsed since case completion',
      other: 'Other'
    },
    global: {
      timed_transition: "TimedTransition::Transitioner"
    }
  ).freeze

  def initialize(code, description)
    self.code = code
    self.description = description
  end

  def ==(other)
    (self.code == other.code) && (self.description == other.description)
  end

  class << self
    def get(code)
      new(code, description_for(code)) unless code.blank?
    end

    def reasons(state)
      reasons_for(state)
    end

    private

    def description_for(code)
      reasons_map.values.reduce({}, :merge).fetch(code)
    rescue KeyError
      raise ReasonNotFoundError, "Reason with code '#{code}' not found"
    end

    def reasons_for(state)
      reasons_map.fetch(state).map { |code, desc| new(code, desc) }
    rescue KeyError
      raise StateNotFoundError, "State with name '#{state}' not found"
    end

    def reasons_map
      TRANSITION_REASONS
    end
  end
end
