module Claims::Calculations

  def calculate_fees_total(category=nil)
    fees.reload
    if category.blank?
      fees.map(&:amount).sum
    else
      __send__("#{category.downcase}_fees").map(&:amount).sum
    end
  end

  def calculate_expenses_total
    expenses.reload.map(&:amount).sum
  end

  def calculate_total
    calculate_fees_total + calculate_expenses_total
  end

  def update_fees_total
    update_column(:fees_total, calculate_fees_total)
  end

  def update_expenses_total
    update_column(:expenses_total, calculate_expenses_total)
  end

  def update_total
    update_column(:total, calculate_total)
  end

end
