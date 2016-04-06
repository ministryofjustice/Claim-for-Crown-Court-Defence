class Claim::LitigatorClaimSubModelValidator < Claim::BaseClaimSubModelValidator

  def has_many_association_names_for_steps
    [
      [
        :defendants
      ],
      [
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
