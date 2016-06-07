class DefendantSubModelValidator < BaseSubModelValidator
  def has_many_association_names
    [ :representation_orders ]
  end
end
