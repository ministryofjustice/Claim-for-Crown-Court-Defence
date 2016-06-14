class ExpenseReason

  attr_reader :reason, :id, :allow_explanatory_text

  def initialize(id, reason, allow_explanatory_text)
    raise ArgumentError.new('Allow explanatory text must be boolean') unless allow_explanatory_text.is_a?(TrueClass) || allow_explanatory_text.is_a?(FalseClass)
    raise ArgumentError.new('Id must be numeric') unless id.is_a?(Fixnum)
    @id = id
    @reason = reason
    @allow_explanatory_text = allow_explanatory_text
  end

  def allow_explanatory_text?
    @allow_explanatory_text
  end

  def ==(other)
    self.id == other.id && self.reason == other.reason && self.allow_explanatory_text? == other.allow_explanatory_text?
  end

  def to_hash
    { id: id, reason: reason, reason_text: allow_explanatory_text? }
  end
end