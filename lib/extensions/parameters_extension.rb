module ParametersExtension

  def zero?
    all? { |key, value| key == '_destroy' || (value.blank? || value.zero?) }
  end

end
