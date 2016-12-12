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
    puts ">>>>>>>>>>>>>> TOTALIZE FOR CLAIM #{klass} #{claim_id} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    ap Expense.all

    values = klass.where(claim_id: claim_id).where("#{net_attribute} IS NOT NULL").pluck(vat_attribute, net_attribute)
    { vat: values.map(&:first).sum, net: values.map(&:last).sum }
  end

  def calculate_expenses_total
    # #reload prevents cloning
    Expense.where(claim_id: self.id).where.not(amount: nil).pluck(:amount).sum
  end

  # def calculate_disbursements_total
  #   # #reload prevents cloning
  #
  #   disbursements = Disbursement.where(claim_id: self.id).where.not(net_amount: nil).pluck(:vat_amount, :net_amount)
  #   { vat: disbursements.map(&:first).sum, net: disbursements.map(&:last).sum }
  # end

  def calculate_total
    a = self.fees_total
    b = self.expenses_total
    c = self.disbursements_total
    a + b + c
  end

  def update_fees_total
    update_column(:fees_total, calculate_fees_total)
    update_column(:fees_vat, calculate_fees_vat)
  end

  def update_expenses_total
    totals = totalize_for_claim(Expense, self.id, :amount, :vat_amount)
    update_column(:expenses_total, totals[:net])
    update_column(:expenses_vat, totals[:vat])
  end

  def update_disbursements_total
    totals = totalize_for_claim(Disbursement, self.id, :net_amount, :vat_amount)
    update_column(:disbursements_vat, totals[:vat])
    update_column(:disbursements_total, totals[:net])
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
    VatRate.vat_amount(self.fees_total, self.vat_date, calculate: self.apply_vat?)
  end

  def calculate_disbursements_vat
    # #reload prevents cloning
    Disbursement.where(claim_id: self.id).where.not(vat_amount: nil).pluck(:vat_amount).sum
  end

  def calculate_total_vat
    self.vat_amount = self.expenses_vat + self.fees_vat + self.disbursements_vat
    # calculate_expenses_vat + calculate_fees_vat + calculate_disbursements_vat
  end

  def update_vat
    update_column(:apply_vat, self.vat_registered?) if self.vat_registered?
    update_column(:vat_amount, calculate_total_vat)
  end

end
