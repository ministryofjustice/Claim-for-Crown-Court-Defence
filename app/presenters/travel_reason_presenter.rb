class TravelReasonPresenter < BasePresenter
  def data_attributes
    {
      reason_text: allow_explanatory_text?
    }
  end
end
