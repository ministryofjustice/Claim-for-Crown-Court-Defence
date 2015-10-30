class ClaimSubModelValidator < BaseSubModelValidator

  # HAS_MANY_ASSOCIATION_NAMES = [ :defendants, :basic_fees, :misc_fees, :fixed_fees, :expenses, :messages, :redeterminations, :documents ]
  # HAS_ONE_ASSOCIATION_NAMES  = [ :assessment, :certification ]

  def has_many_association_names
    [
      :defendants, 
      :basic_fees, 
      :misc_fees, 
      :fixed_fees, 
      :expenses, 
      :messages, 
      :redeterminations, 
      :documents 
    ]
  end

  def has_one_association_names
    [ 
      :assessment, 
      :certification 
    ]
  end

end
