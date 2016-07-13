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
    Expense.where(claim_id: self.id).where.not(amount: nil).pluck(:amount).sum
  end

  def calculate_disbursements_total
    # #reload prevents cloning
    Disbursement.where(claim_id: self.id).where.not(net_amount: nil).pluck(:net_amount).sum
  end

  def calculate_total
    calculate_fees_total + calculate_expenses_total + calculate_disbursements_total
  end

  def update_fees_total
    update_column(:fees_total, calculate_fees_total)
  end

  def update_expenses_total
    update_column(:expenses_total, calculate_expenses_total)
  end

  def update_disbursements_total
    update_column(:disbursements_total, calculate_disbursements_total)
  end

  def update_total
    update_column(:total, calculate_total)
  end

  def calculate_expenses_vat
    if lgfs?
      Expense.where(claim_id: self.id).where.not(vat_amount: nil).pluck(:vat_amount).sum
    else
      VatRate.vat_amount(calculate_expenses_total, self.vat_date, calculate: self.apply_vat?)
    end
  end

  def calculate_fees_vat
    VatRate.vat_amount(calculate_fees_total, self.vat_date, calculate: self.apply_vat?)
  end

  def calculate_disbursements_vat
    # #reload prevents cloning
    Disbursement.where(claim_id: self.id).where.not(vat_amount: nil).pluck(:vat_amount).sum
  end

  def calculate_total_vat
    calculate_expenses_vat + calculate_fees_vat + calculate_disbursements_vat
  end

  def update_vat
    update_column(:apply_vat, self.vat_registered?) if self.vat_registered?
    update_column(:vat_amount, calculate_total_vat)
  end

end
