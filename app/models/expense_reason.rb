class ExpenseReason
  attr_reader :reason, :id, :allow_explanatory_text

  def initialize(id, reason, allow_explanatory_text)
    raise ArgumentError, 'Allow explanatory text must be boolean' unless allow_explanatory_text.is_a?(TrueClass) || allow_explanatory_text.is_a?(FalseClass)
    raise ArgumentError, 'Id must be numeric' unless id.is_a?(Fixnum)
    @id = id
    @reason = reason
    @allow_explanatory_text = allow_explanatory_text
  end

  def allow_explanatory_text?
    @allow_explanatory_text
  end

  def ==(other)
    id == other.id && reason == other.reason && allow_explanatory_text? == other.allow_explanatory_text?
  end

  def to_hash
    { id: id, reason: reason, reason_text: allow_explanatory_text? }
  end
end
