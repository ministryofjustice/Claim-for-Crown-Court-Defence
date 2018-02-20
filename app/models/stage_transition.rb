class StageTransition
  attr_reader :to_stage, :condition

  def initialize(to_stage:, condition: nil, object:)
    @to_stage = to_stage
    @condition = condition
    @object = object
  end

  def valid_condition?
    condition.nil? || condition.call(@object)
  end
end
