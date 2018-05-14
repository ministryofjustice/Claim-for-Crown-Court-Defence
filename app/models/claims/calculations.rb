module Claims::Calculations
  def calculate_fee_total(fee)
    return 0 unless fee
    fee.calculate_amount
    fee.amount || 0
  end

  def calculate_fees_total(category = nil)
    # TODO: revisit this method to understand if it is
    # possible to remove the cumbersome
    # calculate_amount followed by amount.
    fees.reload
    if category.blank?
      calculate_total_for(fees)
    else
      fees_records = public_send(category)
      fees_records.is_a?(Enumerable) ? calculate_total_for(fees_records) : calculate_fee_total(fees_records)
    end
  end

  def calculate_total_for(fees_collection)
    fees_collection.map do |fee|
      calculate_fee_total(fee)
    end.compact.sum
  end

  # returns totals for all klass records belonging to the named claim
  # params:
  # * klass: The class to be totaled
  # * claim_id: the id of the claim
  # * net_attribute: the name of the attribute holding the net amount to be summed
  # * vat_attribute: the name of the attribute holding the vat amount to be summed
  def totalize_for_claim(klass, claim_id, net_attribute, vat_attribute)
    values = klass
             .where(claim_id: claim_id)
             .where(attribute_is_null_to_s(net_attribute))
             .pluck(vat_attribute, net_attribute)
    { vat: values.map { |v| v.first || BigDecimal.new(0.0, 8) }.sum, net: values.map(&:last).sum }
  end

  def attribute_is_null_to_s(net_attribute)
    "#{net_attribute} IS NOT NULL"
  end

  def calculate_expenses_total
    Expense.where(claim_id: id).where.not(amount: nil).pluck(:amount).sum
  end

  def calculate_total
    fees_total + expenses_total + disbursements_total
  end

  def assign_fees_total(categories = [])
    fees_total = categories.inject(0) do |sum, category|
      sum + calculate_fees_total(category)
    end
    fees_vat = calculate_fees_vat(fees_total)
    assign_attributes(
      fees_total: fees_total,
      fees_vat: fees_vat,
      value_band_id: Claims::ValueBands.band_id_for_value(fees_vat + fees_total)
    )
  end

  def update_fees_total
    fees_total = calculate_fees_total
    fees_vat = calculate_fees_vat(fees_total)
    update_columns(fees_vat: fees_vat,
                   fees_total: fees_total,
                   value_band_id: Claims::ValueBands.band_id_for_value(fees_vat + fees_total))
  end

  def assign_expenses_total
    totals = totalize_for_claim(Expense, id, :amount, :vat_amount)
    assign_attributes(expenses_vat: totals[:vat],
                      expenses_total: totals[:net],
                      value_band_id: Claims::ValueBands.band_id_for_value(totals[:net] + totals[:vat]))
  end

  def update_expenses_total
    totals = totalize_for_claim(Expense, id, :amount, :vat_amount)
    update_columns(expenses_vat: totals[:vat],
                   expenses_total: totals[:net],
                   value_band_id: Claims::ValueBands.band_id_for_value(totals[:net] + totals[:vat]))
  end

  def update_disbursements_total
    totals = totalize_for_claim(Disbursement, id, :net_amount, :vat_amount)
    update_columns(disbursements_vat: totals[:vat],
                   disbursements_total: totals[:net],
                   value_band_id: Claims::ValueBands.band_id_for_value(totals[:net] + totals[:vat]))
  end

  def assign_total
    assign_attributes(total: calculate_total)
  end

  def update_total
    update_column(:total, calculate_total)
  end

  def calculate_fees_vat(fees_total)
    VatRate.vat_amount(fees_total, vat_date, calculate: apply_vat?)
  end

  def calculate_total_vat
    self.vat_amount = (expenses_vat || 0.0) + (fees_vat || 0.0) + (disbursements_vat || 0.0)
  end

  def update_vat
    update_column(:apply_vat, vat_registered?) if vat_registered?
    update_column(:vat_amount, calculate_total_vat)
  end

  def assign_vat
    assign_attributes(apply_vat: vat_registered?) if vat_registered?
    assign_attributes(vat_amount: calculate_total_vat)
  end
end
