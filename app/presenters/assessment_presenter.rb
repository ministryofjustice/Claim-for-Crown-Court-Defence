class AssessmentPresenter < BasePresenter

  presents :assessment

 def fees_total
    h.number_to_currency(assessment.fees)
 end

 def expenses_total
  h.number_to_currency(assessment.expenses)
 end

 def total
  h.number_to_currency(assessment.total)
 end

end