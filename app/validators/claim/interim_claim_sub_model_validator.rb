class Claim::InterimClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    [
      [],
      [],
      [],
      %i[
        interim_fee
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
      [],
      %i[
        disbursements
        messages
        redeterminations
        documents
      ]
    ]
  end
end
