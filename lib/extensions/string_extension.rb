module StringExtension
  def zero?
    present? && to_f == 0.0
  end
end
