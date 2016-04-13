class Claim::LitigatorClaimSubModelValidator < Claim::BaseClaimSubModelValidator

  def has_one_association_names_for_steps
    [
      [ ],
      [
        :graduated_fee,
        :fixed_fee,
        :warrant_fee,
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
        :misc_fees,
        :disbursements,
        :expenses,
        :messages,
        :redeterminations,
        :documents
      ]
    ]
  end

end
