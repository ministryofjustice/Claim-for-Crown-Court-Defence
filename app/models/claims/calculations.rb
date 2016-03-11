module Claims::Calculations
  def calculate_fees_total(category=nil)
    fees.reload
    if category.blank?
      fees.map(&:amount).compact.sum
    else
      __send__("#{category.downcase}_fees").map(&:amount).compact.sum
    end
  end

  def calculate_expenses_total
    # #reload prevents cloning
    Expense.where(claim_id: self.id).map(&:amount).sum
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

  def calculate_expenses_vat
    VatRate.vat_amount(calculate_expenses_total, self.vat_date)
  end

  def calculate_fees_vat
    VatRate.vat_amount(calculate_fees_total, self.vat_date)
  end

  def calculate_total_vat
    calculate_expenses_vat + calculate_fees_vat
  end

  def update_vat
    update_column(:apply_vat, self.vat_registered?) if self.vat_registered?

    if self.apply_vat?
      update_column(:vat_amount, calculate_total_vat)
    else
      update_column(:vat_amount, 0.0)
    end
  end

end
