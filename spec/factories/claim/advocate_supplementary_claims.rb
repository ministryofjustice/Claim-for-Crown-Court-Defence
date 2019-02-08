FactoryBot.define do
  factory :advocate_supplementary_claim, class: Claim::AdvocateSupplementaryClaim do
    advocate_base_setup
    offence nil
    case_type nil

    transient do
      with_misc_fee true
    end

    after(:build) do |claim, evaluator|
      claim.creator = claim.external_user
      add_fee(:misc_fee, claim) if evaluator.with_misc_fee
    end
  end
end
