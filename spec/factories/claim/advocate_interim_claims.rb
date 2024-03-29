FactoryBot.define do
  factory :advocate_interim_claim, class: 'Claim::AdvocateInterimClaim' do
    advocate_base_setup
    case_type { nil }

    after(:build) do |claim|
      claim.creator = claim.external_user
    end

    trait :without_fees do
      after(:build) do |claim|
        claim.fees.destroy_all
      end
    end
  end
end
