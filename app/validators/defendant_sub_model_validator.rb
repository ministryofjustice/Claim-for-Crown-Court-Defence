class DefendantSubModelValidator < BaseSubModelValidator

  HAS_MANY_ASSOCIATION_NAMES = [ :representation_orders ]

  def has_many_association_names
    [ :representation_orders ]
  end

end