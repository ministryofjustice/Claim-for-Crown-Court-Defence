class Claim::AdvocateClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    [
      [],
      %i[
        assessment
        certification
      ]
    ]
  end

  def has_many_association_names_for_steps
    [
      %i[], #case_details
      %i[
        defendants
      ], #defendants
      %i[], #offence
      %i[
        basic_fees
        misc_fees
        fixed_fees
        expenses
        messages
        redeterminations
        documents
      ] #fees
    ]
  end
end
