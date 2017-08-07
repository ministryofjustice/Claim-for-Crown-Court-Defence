class Claim::TransferClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    [
      [],
      %i[
        transfer_fee
        assessment
        certification
      ]
    ]
  end

  def has_many_association_names_for_steps
    [
      [],
      [
        :defendants
      ],
      %i[
        misc_fees
        disbursements
        expenses
        messages
        redeterminations
        documents
      ]
    ]
  end
end
