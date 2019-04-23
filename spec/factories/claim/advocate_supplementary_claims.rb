FactoryBot.define do
  factory :advocate_supplementary_claim, class: Claim::AdvocateSupplementaryClaim do
    advocate_base_setup
    offence { nil }
    case_type { nil }

    transient do
      with_misc_fee { true }
    end

    after(:build) do |claim, evaluator|
      claim.creator = claim.external_user || build(:external_user, :advocate)
      if evaluator.with_misc_fee
        fee_type = Fee::MiscFeeType.find_by(unique_code: 'MISPF') || create(:misc_fee_type, :mispf) # persitence needed to prevent ineligible misc fee type deletion
        claim.misc_fees << build(:misc_fee, fee_type: fee_type, claim: claim)
      end
    end

    trait :submitted do
      after(:create) { |c| c.submit! }
    end
  end
end
