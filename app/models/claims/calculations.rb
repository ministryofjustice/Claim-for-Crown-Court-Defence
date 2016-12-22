module Claims::Calculations
  def calculate_fees_total(category=nil)
    fees.reload
    if category.blank?
      fees.map(&:amount).compact.sum
    else
      __send__("#{category.downcase}_fees").map(&:amount).compact.sum
    end
  end

  # returns totals for all klass records belonging to the named claim
  # params:
  # * klass: The class to be totaled
  # * claim_id: the id of the claim
  # * net_attribute: the name of the attribute holding the net amount to be summed
  # * vat_attribute: the name of the attribute holding the vat amount to be summed
  def totalize_for_claim(klass, claim_id, net_attribute, vat_attribute)
    values = klass.where(claim_id: claim_id).where("#{net_attribute} IS NOT NULL").pluck(vat_attribute, net_attribute)
    { vat: values.map{ |v| v.first || BigDecimal.new(0.0, 8) }.sum, net: values.map(&:last).sum }
  end

  def calculate_expenses_total
    Expense.where(claim_id: self.id).where.not(amount: nil).pluck(:amount).sum
  end

  def calculate_total
    a = self.fees_total
    b = self.expenses_total
    c = self.disbursements_total
    a + b + c
  end

  def update_fees_total
    fees_total = calculate_fees_total
    fees_vat = calculate_fees_vat(fees_total)
    update_columns(fees_vat: fees_vat, fees_total: fees_total, value_band_id: Claims::ValueBands.band_id_for_value(fees_vat + fees_total))
  end

  def update_expenses_total
    totals = totalize_for_claim(Expense, self.id, :amount, :vat_amount)
    update_columns(expenses_vat: totals[:vat], expenses_total: totals[:net], value_band_id: Claims::ValueBands.band_id_for_value(totals[:net] + totals[:vat]))
  end

  def update_disbursements_total
    totals = totalize_for_claim(Disbursement, self.id, :net_amount, :vat_amount)
    update_columns(disbursements_vat: totals[:vat], disbursements_total: totals[:net], value_band_id: Claims::ValueBands.band_id_for_value(totals[:net] + totals[:vat]))
  end

  def update_total
    update_column(:total, calculate_total)
  end

  def calculate_fees_vat(fees_total)
    VatRate.vat_amount(fees_total, self.vat_date, calculate: self.apply_vat?)
  end

  def calculate_disbursements_vat
    Disbursement.where(claim_id: self.id).where.not(vat_amount: nil).pluck(:vat_amount).sum
  end

  def calculate_total_vat
    self.vat_amount = (self.expenses_vat || 0.0) + (self.fees_vat || 0.0) + (self.disbursements_vat || 0.0)
  end

  def update_vat
    update_column(:apply_vat, self.vat_registered?) if self.vat_registered?
    update_column(:vat_amount, calculate_total_vat)
  end

end
