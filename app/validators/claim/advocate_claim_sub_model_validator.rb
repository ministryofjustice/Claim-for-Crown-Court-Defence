class Claim::AdvocateClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    [
      [ ],
      [
        :assessment,
        :certification
      ]
    ]
  end

  def has_many_association_names_for_steps
    [
      [
        :defendants
      ],
      [
        :basic_fees,
        :misc_fees,
        :fixed_fees,
        :expenses,
        :messages,
        :redeterminations,
        :documents
      ]
    ]
  end
end
