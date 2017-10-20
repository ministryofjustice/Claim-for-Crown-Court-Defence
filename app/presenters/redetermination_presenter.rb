class RedeterminationPresenter < BasePresenter
  presents :redetermination

  def fees_total
    h.number_to_currency(redetermination.fees)
  end

  def expenses_total
    h.number_to_currency(redetermination.expenses)
  end

  def disbursements_total
    h.number_to_currency(redetermination.disbursements)
  end

  def vat_amount
    h.number_to_currency(redetermination.vat_amount)
  end

  def total
    h.number_to_currency(redetermination.total)
  end

  def total_inc_vat
    h.number_to_currency(redetermination.total + (redetermination.vat_amount || 0))
  end
end
