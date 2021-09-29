class FormAnswer
  attr_reader :key, :label, :other

  def initialize(key, label, id, other: false)
    @key = key
    @label = label
    @id = id
    @other = other
  end

  def id
    return { id: @id, other: true } if @other

    @id
  end
end
