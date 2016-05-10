class Claim::TransferClaimSubModelValidator < Claim::BaseClaimSubModelValidator

  def has_one_association_names_for_steps
    [
      [ ],
      [
        :transfer_fee,
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
        :messages,
        :redeterminations,
        :documents
      ]
    ]
  end

end
