class Claim::InterimClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    [
      [
        :case_type,
        :court,
        :case_number,
        :advocate_category,
        :offence,
        :case_concluded_at
      ],
      [
        :total
      ]
    ]
  end
end
