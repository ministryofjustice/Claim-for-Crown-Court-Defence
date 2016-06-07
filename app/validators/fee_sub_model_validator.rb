class FeeSubModelValidator < BaseSubModelValidator
  def has_many_association_names
    [ :dates_attended ]
  end
end
