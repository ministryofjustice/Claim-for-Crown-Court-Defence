class TypedFeeAmountSection < TypedFeeSection

  element :amount, 'input.total'
  element :rate, nil

  def populated?
    amount.value.size > 0
  end
end
