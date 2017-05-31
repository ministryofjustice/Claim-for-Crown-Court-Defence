module ArrayExtension
  def zeroize_nils(value = 0.00)
    map { |element| element.blank? ? value : element }
  end

  def zeroize_nils!(value = 0.00)
    replace(zeroize_nils(value))
  end

  def average(total = size)
    any? ? sum.to_f / total : 0
  end
end
