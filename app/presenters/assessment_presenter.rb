class AssessmentPresenter < BasePresenter
  presents :assessment

  def fees_total
    h.number_to_currency(assessment.fees)
  end

  def expenses_total
    h.number_to_currency(assessment.expenses)
  end

  def disbursements_total
    h.number_to_currency(assessment.disbursements)
  end

  def vat_amount
    h.number_to_currency(assessment_vat_amount)
  end

  def total
    h.number_to_currency(assessment_total)
  end

  def total_inc_vat
    h.number_to_currency(assessment_total + assessment_vat_amount)
  end

  private

  def assessment_total
    assessment.total || 0
  end

  def assessment_vat_amount
    assessment.vat_amount || 0
  end
end
