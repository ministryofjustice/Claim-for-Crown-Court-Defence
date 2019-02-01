FactoryBot.define do
  factory :advocate_supplementary_claim, class: Claim::AdvocateSupplementaryClaim do
    advocate_base_setup
    offence nil
    # case_type nil # TODO: SUPPLEMENTARY_CLAIM_TODO - should be nil, need to determine if fee calc requires it

    after(:build) do |claim|
      claim.creator = claim.external_user
    end
  end
end
