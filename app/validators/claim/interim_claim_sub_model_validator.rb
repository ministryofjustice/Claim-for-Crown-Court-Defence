class Claim::InterimClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    [
      [ ],
      [
        :interim_fee,
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
        :disbursements,
        :messages,
        :redeterminations,
        :documents
      ]
    ]
  end
end
