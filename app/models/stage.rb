class Stage
  include Comparable

  attr_reader :name, :transitions

  def initialize(name:, transitions: [], object:)
    @name = name
    @object = object
    @transitions = initialize_transitions(transitions || [])
  end

  def first_valid_transition
    transitions.inject(nil) do |_mem, transition|
      break transition.to_stage if transition.valid_condition?
    end
  end

  def to_sym
    name.to_sym
  end

  def <=>(other)
    to_sym <=> other&.to_sym
  end

  private

  def initialize_transitions(transitions)
    transitions.map do |transition|
      StageTransition.new(to_stage: transition[:to_stage], condition: transition[:condition], object: @object)
    end
  end
end
