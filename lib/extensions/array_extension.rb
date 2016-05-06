module ArrayExtension

  def zeroize_nils(value = 0.00)
    map { |element| element.blank? ? value : element }
  end

  def zeroize_nils!(value = 0.00)
    replace(zeroize_nils(value))
  end

end
