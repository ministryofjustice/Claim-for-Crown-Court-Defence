class ExpenseSubModelValidator < BaseSubModelValidator

  # TODO to be removed if not required
  # HAS_MANY_ASSOCIATION_NAMES = [ :dates_attended ]

  def has_many_association_names
    [ :dates_attended ]
  end

end