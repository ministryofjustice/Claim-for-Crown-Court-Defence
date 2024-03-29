class StageTransition
  attr_reader :to_stage, :condition

  def initialize(to_stage:, object:, condition: nil)
    @to_stage = to_stage.to_sym
    @condition = condition
    @object = object
  end

  def valid_condition?
    condition.nil? || condition.call(@object)
  end
end
