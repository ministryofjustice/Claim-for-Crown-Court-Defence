class AssessmentPresenter < BasePresenter

  presents :assessment

  def fees_total
    h.number_to_currency(assessment.fees)
  end

  def expenses_total
    h.number_to_currency(assessment.expenses)
  end

  def vat_amount
    h.number_to_currency(assessment.vat_amount)
  end

  def total
    h.number_to_currency(assessment.total || 0)
  end

  def total_inc_vat
    h.number_to_currency((assessment.total || 0) + assessment.vat_amount)
  end

end
