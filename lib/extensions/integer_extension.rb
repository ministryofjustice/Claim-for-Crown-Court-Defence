module IntegerExtension
  def or_one
    [self, 1].compact.max
  end
end
