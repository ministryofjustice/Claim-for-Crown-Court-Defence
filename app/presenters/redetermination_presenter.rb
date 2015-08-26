class RedeterminationPresenter < BasePresenter

  presents :redetermination

  def fees
    h.number_to_currency(redetermination.fees)
  end

  def expenses
    h.number_to_currency(redetermination.expenses)
  end

  def total
    h.number_to_currency(redetermination.total)
  end

  def created_at
    redetermination.created_at.strftime(Settings.date_time_format.to_s)
  end


end