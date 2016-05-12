class TypedFeeAmountSection < TypedFeeSection

  element :amount, 'input.amount'
  element :rate, nil

  def populated?
    amount.value.size > 0
  end
end
